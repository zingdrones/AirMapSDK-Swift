//
//  TelemetryTests.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 12/1/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import XCTest

@testable import AirMap
import Nimble
import CocoaAsyncSocket

class TelemetryTests: TestCase {
	
	let iv = AirMapTelemetry.generateIV()
	let key: [UInt8] = [201, 49, 58, 234, 67, 135, 252, 215, 251, 132, 90, 119, 192, 127, 77, 39,
	                    234, 70, 138, 229, 75, 193, 234, 177, 147, 236, 126, 245, 219, 47, 242, 86]
	

	let position: Airmap.Telemetry.Position = {

		let position = Airmap.Telemetry.Position.Builder()
		position.setAltitudeMMsl(150)
		position.setLatitude(41.5)
		position.setLongitude(-118.7)
		position.setTimestamp(NSDate().timeIntervalSince1970.milliseconds)
		
		return try! position.build()
	}()
	
	class MockTelemetryServerSocket: GCDAsyncUdpSocket, GCDAsyncUdpSocketDelegate {
		
		var messageHandler: (NSData -> Void)!
		
		func bind() {
			try! bindToPort(Config.AirMapTelemetry.port, interface: "loopback")
			try! beginReceiving()
		}
		
		@objc func udpSocket(sock: GCDAsyncUdpSocket, didReceiveData data: NSData, fromAddress address: NSData, withFilterContext filterContext: AnyObject?) {
			messageHandler(data)
		}
	}
	
	class MockTelemetryClientSocket: AirMapTelemetry.Socket, GCDAsyncUdpSocketDelegate {
		
		override func sendData(data: NSData) {
			sendData(data, toHost: "loopback", port: Config.AirMapTelemetry.port, withTimeout: 10, tag: 0)
		}
	}
	
	func testSendingData() {
		
		let serverSocket = MockTelemetryServerSocket()
		serverSocket.setDelegate(serverSocket)
		serverSocket.setDelegateQueue(AirMapTelemetry.serialQueue)
		serverSocket.bind()

		let clientSocket = MockTelemetryClientSocket()
		
		let payload = position.telemetryData().AES256CBCEncrypt(key: key, iv: iv)!
		let flightId = "flight|1234567890abcdef"
		let packet = AirMapTelemetry.Packet(serial: 1, flightId: flightId, payload: payload, encryption: .AES256CBC, encryptionData: NSData(bytes: iv))
		let packetData = packet.data()
		
		waitUntil { done in
			
			serverSocket.messageHandler = { receivedData in
				expect(receivedData).to(equal(packetData))
				serverSocket.close()
				clientSocket.close()
				done()
			}
			clientSocket.sendData(packetData)
		}
	}
	
	func testMessageType() {
		
		expect(Airmap.Telemetry.Position().messageType)
			.to(equal(ProtoBufMessage.MessageType.Position))
		
		expect(Airmap.Telemetry.Speed().messageType)
			.to(equal(ProtoBufMessage.MessageType.Speed))
		
		expect(Airmap.Telemetry.Barometer().messageType)
			.to(equal(ProtoBufMessage.MessageType.Barometer))
	}
	
	func testMessageSerialization() {
		
		let messageData = position.telemetryData()

		var range = NSRange()
		
		var messageType: UInt16 = 0
		range.length = sizeofValue(messageType)
		messageData.getBytes(&messageType, range: range)
		range.location += range.length
		expect(messageType).to(equal(ProtoBufMessage.MessageType.Position.rawValue))
		
		var payloadLength: UInt16 = 0
		range.length = sizeofValue(payloadLength)
		messageData.getBytes(&payloadLength, range: range)
		range.location += range.length
		expect(Int(payloadLength)).to(equal(position.data().length))

		range.length = Int(payloadLength)
		let telemetryPayload = messageData.subdataWithRange(range)
		expect(telemetryPayload).to(equal(position.data()))
	}
	
	func testPacketSerialization() {
		
		let payload = position.telemetryData().AES256CBCEncrypt(key: key, iv: iv)!

		let flightId = "flight|1234567890abcdef"
		let ivData = NSData(bytes: iv)
		let packet = AirMapTelemetry.Packet(serial: 123, flightId: flightId, payload: payload, encryption: .AES256CBC, encryptionData: ivData)
		let packetData = packet.data()
		
		var range = NSRange()
		
		var serial: UInt32 = 0
		range.length = sizeofValue(serial)
		packetData.getBytes(&serial, range: range)
		range.location += range.length
		expect(serial).to(equal(123))
		
		var flightIdLength: UInt8 = 0
		range.length = sizeofValue(flightIdLength)
		packetData.getBytes(&flightIdLength, range: range)
		range.location += range.length
		
		var flightIdData = [UInt8](count: Int(flightIdLength), repeatedValue: 0)
		range.length = flightIdData.count
		packetData.getBytes(&flightIdData, range: range)
		range.location += range.length
		expect(String(bytes: flightIdData, encoding: NSUTF8StringEncoding)).to(equal(flightId))
		
		var encryption: UInt8 = 0
		range.length = sizeofValue(encryption)
		packetData.getBytes(&encryption, range: range)
		range.location += range.length
		expect(encryption).to(equal(AirMapTelemetry.Packet.EncryptionType.AES256CBC.rawValue))
		
		var ivBytes = [UInt8](count: 16, repeatedValue: 0)
		range.length = ivBytes.count
		packetData.getBytes(&ivBytes, range: range)
		range.location += range.length
		expect(ivBytes).to(equal(iv))
		
		range.length = packetData.length - range.location
		let packetPayload = packetData.subdataWithRange(range)
		expect(packetPayload).to(equal(payload))
	}
	
	func testEncryption() {
		
		let secret = "s3cr3t".utf8Data
		let encypted = secret.AES256CBCEncrypt(key: key, iv: iv)
		let decrypted = encypted?.AES256CBCDecrypt(key: key, iv: iv)
		expect(decrypted).to(equal(secret))
	}
	
	func testSendingTelemetry() {
		
		let serverSocket = MockTelemetryServerSocket()
		serverSocket.setDelegate(serverSocket)
		serverSocket.setDelegateQueue(AirMapTelemetry.serialQueue)
		serverSocket.bind()
//		serverSocket.close()

		let clientSocket = MockTelemetryClientSocket()
		AirMapTelemetry.Session.socket = clientSocket
		
		let payload = position.telemetryData().AES256CBCEncrypt(key: key, iv: iv)!
		
		let flightId = "flight|1234567890abcdef"
		let ivData = NSData(bytes: iv)
		let packet = AirMapTelemetry.Packet(serial: 123, flightId: flightId, payload: payload, encryption: .AES256CBC, encryptionData: ivData)
		let packetData = packet.data()

		let flight = AirMapFlight()
		flight.flightId = flightId
		
		serverSocket.messageHandler = { receivedData in
			expect(receivedData).to(equal(packetData))
		}
		
		let coordinate = CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude)
		try! AirMap.sendTelemetryData(flight, coordinate: coordinate, altitude: position.altitudeMMsl)
	}
	
}




























