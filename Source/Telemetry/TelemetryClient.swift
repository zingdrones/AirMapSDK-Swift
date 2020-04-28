//
//  Airmap_Telemetry.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 12/5/16.
//  Copyright 2018 AirMap, Inc.
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

import Swift
import RxSwift
import RxSwiftExt
import GRPC
import NIO
import NIOHPACK

class TelemetryClient {

	func sendTelemetry(flight: AirMapFlightId, report: Telemetry_Report) {
		reports.onNext((flight, report))
	}

	private typealias FlightReport = (flightId: AirMapFlightId, report: Telemetry_Report)

	private let reports = PublishSubject<FlightReport>()
	private let disposeBag = DisposeBag()
	private let scheduler = MainScheduler.instance


	private var client: Telemetry_CollectorClient?
	private var call: BidirectionalStreamingCall<Telemetry_Update.FromProvider, Telemetry_Update.ToProvider>?

	private let connection: ClientConnection
	private let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
	private let tls = ClientConnection.Configuration.TLS()
	private let target = ConnectionTarget.hostAndPort(
							Constants.Telemetry.host,
							Int(Constants.Telemetry.port))

	init() {

		let configuration = ClientConnection.Configuration(target: target, eventLoopGroup: group, tls: tls)
		connection = ClientConnection(configuration: configuration)
		print(target)

		let spatial = reports
			.filter(TelemetryClient.isSpatialReport)
			.throttle(Constants.Telemetry.SampleRate.spatial, scheduler: scheduler)

		let atmospheric = reports
			.filter(TelemetryClient.isAtmosphericReport)
			.throttle(Constants.Telemetry.SampleRate.atmospheric, scheduler: scheduler)

		let updates = Observable
			.merge(spatial, atmospheric)
			.map(TelemetryClient.trafficUpdate)

		updates
			.subscribe(onNext: { [weak self] (updateFromProvider) in
				let loop = self?.call?.sendMessage(updateFromProvider)
//				loop.
			})
			.disposed(by: disposeBag)

		if let token = AirMap.authToken {
			connect(with: token)
		}
	}

	private func connect(with accessToken: String) {
		print("connect(with accessToken")
		print("connect(with \(accessToken)")

		let headers = HPACKHeaders([("authorization", "Bearer \(accessToken)"), ("x-api-key", AirMap.configuration.apiKey)])
		let defaultCallOptions = CallOptions(customMetadata: headers)
		client = Telemetry_CollectorClient(channel: connection, defaultCallOptions: defaultCallOptions)

		call = client?.connectProvider(handler: { (updateToProvider) in
			print("updateToProvider")
			print(updateToProvider)
		})

		call?.status.whenFailure({ (error) in
			print("error")
			print(error)
		})

		call?.status.whenSuccess({ (status) in
			print("error")
			print(status)
		})

		call?.status.whenComplete({ (complete) in
			print("whenComplete")
			print(complete)
		})

	}

	private func disconnect() {
		_ = call?.cancel()
		client = nil
		call = nil
	}
}

extension TelemetryClient {

	private static func isSpatialReport(flightReport: FlightReport) -> Bool {
		if let details = flightReport.report.details, case .spatial = details { return true } else { return false }
	}

	private static func isAtmosphericReport(flightReport: FlightReport) -> Bool {
		if let details = flightReport.report.details, case .atmosphere(flightReport.report.atmosphere) = details { return true } else { return false }
	}

	private static func trafficUpdate(from next: FlightReport) -> Telemetry_Update.FromProvider {
		return .with({ (update) in
			update.report = next.report
		})
	}
}
