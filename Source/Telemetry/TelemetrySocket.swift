//
//  TelemetrySocket.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 4/7/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import CocoaAsyncSocket
import RxSwift
import Log

internal class TelemetrySocket: NSObject {

	var keyState: AirMapTelemetry.KeyState = .Unknown
	let comm: Variable<Comm?> = Variable(nil)
	let disposeBag = DisposeBag()

	lazy var socket: GCDAsyncUdpSocket = {
		return GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
	}()

	func retreiveCommunicationKey(flight: AirMapFlight) -> Observable<Comm> {

		AirMap.logger.debug("Requesting AirMapTelemetry Key")

		keyState = .Retreiving

		if let comm = comm.value where comm.isValid() {
			return Observable.create { (observer: AnyObserver<Comm>) -> Disposable in
				observer.onNext(comm)
				return NopDisposable.instance
			}
		}

		return AirMap.flightClient.getCommKey(flight)
			.doOnNext { comm in
				self.keyState = .Finished
				self.comm.value = comm
		}
	}

	func connect() -> Bool {

		do {
			AirMap.logger.debug("Connecting AirMapTelemetrySocket")
			try socket.connectToHost(Config.AirMapTelemetry.host, onPort: UInt16(Config.AirMapTelemetry.port))
			try socket.beginReceiving()
			AirMap.logger.debug("AirMapTelemetrySocket Connected")
			return true
		} catch {
			AirMap.logger.error("AirMapTelemetrySocket Error \(error)")
			return false
		}
	}

	func sendMessage(messageData: NSData) {

		if !socket.isConnected() { connect() }
		socket.sendData(messageData, withTimeout: 10, tag: 100)
	}
	
}

extension TelemetrySocket: GCDAsyncUdpSocketDelegate {
	
	@objc func udpSocket(sock: GCDAsyncUdpSocket, didConnectToAddress address: NSData) {
		AirMap.logger.debug("AirMapTelemetrySocket DidConnect")
	}

	@objc func udpSocket(sock: GCDAsyncUdpSocket, didNotConnect error: NSError?) {
		AirMap.logger.error("AirMapTelemetrySocket DidNotConnect", error?.localizedDescription ?? "")
	}
}
