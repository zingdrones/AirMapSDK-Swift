//
//  TelemetryTests.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/5/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

@testable import AirMap
import Nimble
import CocoaAsyncSocket

class TelemetryTests: TestCase, GCDAsyncUdpSocketDelegate {

	let iv = AirMapTelemetry.generateIV()
	let key: [UInt8] = [201, 49, 58, 234, 67, 135, 252, 215, 251, 132, 90, 119, 192, 127, 77, 39,
	                    234, 70, 138, 229, 75, 193, 234, 177, 147, 236, 126, 245, 219, 47, 242, 86]

	class MockTelemetryServerSocket: TelemetrySocket {

		var messageHandler: (NSData -> Void)!

		override func connect() -> Bool {
			if socket.isConnected() { return true }
			try! socket.bindToPort(Config.AirMapTelemetry.port, interface: "loopback")
			try! socket.beginReceiving()
			return true
		}

		func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
			messageHandler(data)
		}
	}

	class MockTelemetryClientSocket: TelemetrySocket {

		override func connect() -> Bool {
			if socket.isConnected() { return true }
			try! socket.connectToHost("loopback", onPort: Config.AirMapTelemetry.port)
			try! socket.beginReceiving()
			return true
		}
	}

	let serverSocket = MockTelemetryServerSocket()
	let clientSocket = MockTelemetryClientSocket()

	func testSendingArbitraryData() {

		serverSocket.connect()
		clientSocket.connect()

		waitUntil { done in

			let message = "I <3 Drones".dataUsingEncoding(NSUTF8StringEncoding)!

			self.serverSocket.messageHandler = { data in
				expect(data).to(equal(message))
				done()
			}
			self.clientSocket.sendMessage(message)
		}
	}

	func testTelemetryEncoding() {

		do {
			let flight = FlightFactory.defaultFlight()
			let altitude = 100
			let groundSpeedMs = 5
			let trueHeading = 090
			let baro = 1_013.21
			let timestamp = NSDate()

			guard let encodedData = AirMapTelemetry.encodedTelemetryData(
				iv: iv, key: key, flightId: flight.flightId, coordinate: flight.coordinate,
				altitude: altitude, groundSpeedMs: groundSpeedMs, trueHeading: trueHeading, baro: baro,
				timestamp: timestamp) else {
					fail("Could not encode telemetry data")
					return
			}

			let message = try OpenMessage.parseFromData(encodedData)
			expect(message.flightId).to(equal(flight.flightId))
			expect(message.iv).to(equal(AirMapTelemetry.dataFromIV(iv)))

			guard let decryptedPayload = AirMapTelemetry.decryptMessage(message.payload, iv: iv, key: key)
				else { fail("Could not decrypt message payload"); return }

			let payload = try SecretMessage.parseFromData(decryptedPayload)

			expect(Double(payload.latitude)).to(beCloseTo(flight.coordinate.latitude))
			expect(Double(payload.longitude)).to(beCloseTo(flight.coordinate.longitude))
			expect(Int(payload.altitude)).to(equal(altitude))
			expect(Int(payload.groundSpeedMs)).to(equal(groundSpeedMs))
			expect(Int(payload.trueHeading)).to(equal(trueHeading))
			expect(Double(payload.baro)).to(beCloseTo(baro))
			// This test will fail because of a loss in sub-second precision. The protobufs should be updated
			// to use Double instead of UInt64 in order to capture milliseconds. ^AM
			expect(NSTimeInterval(payload.timestamp)).to(beCloseTo(timestamp.timeIntervalSince1970))

		} catch {
			fail("Could not parse message from encoded data")
		}
	}

	func testEncryption() {

		let secret = "passw0rd".dataUsingEncoding(NSUTF8StringEncoding)!
		let encypted = AirMapTelemetry.encryptMessage(secret, iv: iv, key: key)!
		let decrypted = AirMapTelemetry.decryptMessage(encypted, iv: iv, key: key)!
		expect(decrypted).to(equal(secret))
	}

}
