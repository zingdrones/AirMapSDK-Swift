//
//  TelemetryClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 4/5/20.
//  Copyright 2020 AirMap, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import RxSwift
import NIO
import NIOHPACK
import Logging
import GRPC

public protocol TelemetryClientDelegate: class {
	func airMapTelemetryDidChangeConnectivity(_ state: ConnectivityState)
	func airMapTelemetryDidCatch(_ error: Error)
	func airMapTelemetryDidReceive(_ ack: System_Ack)
}

enum TelemetryClientError: Error {
	case unauthenticated
	case missingReportDetails
	case missingFlightIdentity
}

public class TelemetryClient {

	// MARK: Public

	public weak var delegate: TelemetryClientDelegate?

	/// Designated client initializer
	public init(delegate: TelemetryClientDelegate?) throws {

		self.delegate = delegate
		setupBindings()
		try! connect()
	}

	/// Connect to the telemetry service
	private func connect() throws {

		guard AirMap.isAuthorized, let token = AirMap.authToken else {
			throw TelemetryClientError.unauthenticated
		}

		let eventLoop = MultiThreadedEventLoopGroup(numberOfThreads: 1)

		let connection = ClientConnection
			.secure(group: eventLoop)
			.withConnectionTimeout(minimum: .seconds(10))
			.withConnectionBackoff(initial: .seconds(5))
			.withConnectionBackoff(maximum: .seconds(15))
			.withConnectivityStateDelegate(self)
			.withErrorDelegate(self)
			.connect(host: Constants.Telemetry.host, port: Constants.Telemetry.port)

		let client = Telemetry_CollectorClient(channel: connection)

		let options = CallOptions(customMetadata: HPACKHeaders([
			("authorization", "Bearer: \(token)"),
			("x-api-key", AirMap.configuration.apiKey)
		]))

		let stream = client.connectProvider(callOptions: options) { (update) in
			guard let details = update.details else { return }
			switch details {
			case .ack(let ack):
				self.delegate?.airMapTelemetryDidReceive(ack)
			case .status(let status):
				let statusJSON = (try? status.jsonString()) ?? ""
				AirMap.logger.debug("received status response", metadata: ["status": .string(statusJSON)])
			}
		}

		self.client = client
		self.eventLoop = eventLoop
		self.stream = stream
	}

	/// Disconnect from the telemetry service
	private func disconnect() {

		do {
			try stream?.sendEnd().wait()
			try client?.channel.close().wait()
			try eventLoop?.syncShutdownGracefully()
		} catch {
			AirMap.logger.error("failed to close connection", metadata: ["error": .string(error.localizedDescription)])
		}

		client = nil
		eventLoop = nil
	}

	/// Send a telemetry report
	public func send(report: Telemetry_Report) throws {

		// Assert that the report contains details
		guard report.details != nil else {
			throw TelemetryClientError.missingReportDetails
		}

		// Assert that identities contain a flight/operation id
		if !report.identities.contains(where: { (identity) -> Bool in
			switch identity.details {
			case .operation(let operation):
				return operation.hasOperationID
			default:
				return false
			}
		}) {
			throw TelemetryClientError.missingFlightIdentity
		}

		reports.onNext(report)
	}

	// MARK: - Private

	private let reports = PublishSubject<Telemetry_Report>()
	private let disposeBag = DisposeBag()

	private var eventLoop: MultiThreadedEventLoopGroup?
	private var client: Telemetry_CollectorClient?
	private var stream: BidirectionalStreamingCall<Telemetry_Update.FromProvider, Telemetry_Update.ToProvider>?

	private func setupBindings() {

//		let authToken = AirMap.authService.authState.mapAt(\.accessToken)

		// Individually throttle each report type
		let rateLimit = Constants.Telemetry.RateLimit.self
		let bgScheduler = ConcurrentDispatchQueueScheduler(qos: .utility)

		let atmosphere = reports
			.filter { if case .atmosphere = $0.details { return true } else { return false } }
			.throttle(rateLimit.atmosphere, scheduler: bgScheduler)

		let spatial = reports
			.filter { if case .spatial = $0.details { return true } else { return false } }
			.throttle(rateLimit.spatial, scheduler: bgScheduler)

		let vehicle = reports
			.filter { if case .vehicle = $0.details { return true } else { return false } }
			.throttle(rateLimit.vehicle, scheduler: bgScheduler)

		// Merge throttled report types
		Observable.merge([atmosphere, spatial, vehicle])
			.subscribe(weak: self, onNext: TelemetryClient.sendReport)
			.disposed(by: disposeBag)
	}

	private func sendReport(_ report: Telemetry_Report) {
		stream?.sendMessage(.with({ $0.details = .report(report) })).whenFailure({ (error) in
			self.delegate?.airMapTelemetryDidCatch(error)
		})
	}

	deinit {
		disconnect()
	}
}

extension TelemetryClient: ConnectivityStateDelegate {

	public func connectivityStateDidChange(from oldState: ConnectivityState, to newState: ConnectivityState) {
		AirMap.logger.debug("telemetry client transitioned state",
							metadata: [
								"old_state": .string(String(describing: oldState)),
								"new_state": .string(String(describing: newState)),
		])
		// TODO: Check expiry of token before reconnect and update call options
		delegate?.airMapTelemetryDidChangeConnectivity(newState)
	}
}

extension TelemetryClient: ClientErrorDelegate {

	public func didCatchError(_ error: Error, logger: Logger, file: StaticString, line: Int) {
		delegate?.airMapTelemetryDidCatch(error)
	}
}
