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
import ProtocolBuffers
import CryptoSwift


class TelemetryTests: TestCase {
	
	let iv = AirMapTelemetry.generateIV()
	let key: [UInt8] = "00001111222233334444555566667777".data(using: .utf8)!.bytes
	
	lazy var aes: AES = {
		return try! AES(key: self.key, blockMode: .CBC(iv: iv))
	}()

	let position: Airmap.Telemetry.Position = {

		let position = Airmap.Telemetry.Position.Builder()
		position.setAltitudeMsl(150)
		position.setLatitude(41.5)
		position.setLongitude(-118.7)
		position.setTimestamp(NSDate().timeIntervalSince1970.milliseconds)
		
		return try! position.build()
	}()
	
	class MockTelemetryServerSocket: GCDAsyncUdpSocket, GCDAsyncUdpSocketDelegate {
		
		var messageHandler: ((Data) -> Void)!
		
		func bind() {
			try! bind(toPort: Constants.AirMapTelemetry.port, interface: "loopback")
			try! beginReceiving()
		}
		
		func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
			messageHandler(data)
		}
	}
	
	class MockTelemetryClientSocket: AirMapTelemetry.Socket, GCDAsyncUdpSocketDelegate {
		
		override func sendData(_ data: Data) {
			send(data, toHost: "loopback", port: Constants.AirMapTelemetry.port, withTimeout: 10, tag: 0)
		}
	}
	
	func testSendingData() {
		
		let serverSocket = MockTelemetryServerSocket()
		serverSocket.setDelegate(serverSocket)
		serverSocket.setDelegateQueue(AirMapTelemetry.Session.serialQueue)
		serverSocket.bind()

		let clientSocket = MockTelemetryClientSocket()
		
		let payload = try! aes.encrypt(position.telemetryBytes())
		let flightId = "flight|1234567890abcdef"
		let packet = AirMapTelemetry.Packet(serial: 1, flightId: flightId, payload: payload, encryption: .aes256cbc, iv: iv)
		let packetData = Data(packet.bytes())
		
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
			.to(equal(ProtoBufMessage.MessageType.position))
		
		expect(Airmap.Telemetry.Attitude().messageType)
			.to(equal(ProtoBufMessage.MessageType.attitude))

		expect(Airmap.Telemetry.Speed().messageType)
			.to(equal(ProtoBufMessage.MessageType.speed))
		
		expect(Airmap.Telemetry.Barometer().messageType)
			.to(equal(ProtoBufMessage.MessageType.barometer))
	}
	
	func scan<T: UnsignedInteger>(_ type: T.Type, from bytes: [UInt8], offset: inout Int) -> T {
		
		let size = MemoryLayout<T>.size
		let slice = bytes[offset..<offset+size]
		offset = offset.advanced(by: size)
		
		let newType = slice.withUnsafeBufferPointer { pointer in
			pointer.baseAddress?.withMemoryRebound(to: T.self, capacity: size, { pointer in
				return pointer.pointee
			})
		}
		
		return newType!
	}

	func testMessageSerialization() {
		
		let bytes = position.telemetryBytes()
		var offset = bytes.startIndex
		
		let messageType = scan(UInt16.self, from: bytes, offset: &offset).bigEndian
		expect(Airmap.Telemetry.Position.MessageType(rawValue: messageType)).to(equal(Airmap.Telemetry.Position.MessageType.position))
		
		let payloadLength = scan(UInt16.self, from: bytes, offset: &offset).bigEndian
		expect(payloadLength).to(equal(UInt16(position.serializedSize())))

		let payload = bytes.suffix(from: offset)
		expect(Data(payload)).to(equal(position.data()))
	}
	
	
	func testPacketSerialization() {
		
		let encryptedPayload = try! aes.encrypt(position.telemetryBytes())

		let flightId = "flight|1234567890abcdef"
		let packet = AirMapTelemetry.Packet(serial: 123, flightId: flightId, payload: encryptedPayload, encryption: .aes256cbc, iv: iv)
		let bytes = packet.bytes()
		
		var offset = bytes.startIndex
		
		let serial = scan(UInt32.self, from: bytes, offset: &offset).bigEndian
		expect(serial).to(equal(123))
		
		let flightIdLength = scan(UInt8.self, from: bytes, offset: &offset)
		expect(Int(flightIdLength)).to(equal(flightId.utf8.count))

		let flightIdBytes = bytes[offset..<offset+Int(flightIdLength)]
		offset = offset.advanced(by: Int(flightIdLength))

		let flightIdString = String(data: Data(flightIdBytes), encoding: .utf8)
		expect(flightIdString).to(equal(flightId))

		let encryption = scan(UInt8.self, from: bytes, offset: &offset)
		expect(encryption).to(equal(AirMapTelemetry.Packet.EncryptionType.aes256cbc.rawValue))
		
		let ivBytes = bytes[offset..<offset+16]
		offset = offset.advanced(by: ivBytes.count)
		expect(Array(ivBytes)).to(equal(iv))
		
		let packetPayload = bytes[offset..<bytes.endIndex]
		expect(Array(packetPayload)).to(equal(encryptedPayload))
	}
	
	func testEncryption() {
		
		let secret = "s3cr3t".data(using: .utf8)!
		let encypted = try! aes.encrypt(secret)
		let decrypted = try! aes.decrypt(encypted)
		expect(decrypted).to(equal(secret.bytes))
	}
	
	func testSendingTelemetry() {
		
		let serverSocket = MockTelemetryServerSocket()
		serverSocket.setDelegate(serverSocket)
		serverSocket.setDelegateQueue(AirMapTelemetry.Session.serialQueue)
		serverSocket.bind()

		let clientSocket = MockTelemetryClientSocket()
		AirMapTelemetry.Session.socket = clientSocket
		
		let encryptedPayload = try! aes.encrypt(position.telemetryBytes())
		
		let flightId = "flight|1234567890abcdef"
		let packet = AirMapTelemetry.Packet(serial: 123, flightId: flightId, payload: encryptedPayload, encryption: .aes256cbc, iv: iv)
		let packetData = packet.bytes()

		let flight = AirMapFlight()
		flight.flightId = flightId
		
		serverSocket.messageHandler = { receivedData in
			expect(receivedData).to(equal(Data(bytes: packetData)))
		}
		
		let coordinate = CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude)
		try! AirMap.sendTelemetryData(flight, coordinate: coordinate, altitudeAgl: nil, altitudeMsl: position.altitudeMsl)
	}
	
	func testDecryptPacket() {
		
		let key = "00001111222233334444555566667777".data(using: .utf8)!.bytes
		let iv = Array(key[0..<16])
		let flightId = "flight|JvzMvdJFgD0E9yFNpRQ6AhpO2ZZw"
		
		expect(key.count).to(equal(32))
		expect(iv.count).to(equal(16))
		
		let packetBase64 = "AAAAASNmbGlnaHR8SnZ6TXZkSkZnRDBFOXlGTnBSUTZBaHBPMlpadwEwMDAwMTExMTIyMjIzMzMzb2yXSrFrZxNNmZ6LwjLT6aSp9BXiF0E/d9ASIuwI4YmyJYccplg+XPTG9L1NRqxLbAD7QuUOcI/6R8xjBCzCVA=="
		let bytes = Data(base64Encoded: packetBase64, options: Data.Base64DecodingOptions())!.bytes
		
		var offset = bytes.startIndex
		
		let serial = scan(UInt32.self, from: bytes, offset: &offset).bigEndian
		expect(serial).to(equal(1))
		
		let flightIdLength = scan(UInt8.self, from: bytes, offset: &offset)
		expect(Int(flightIdLength)).to(equal(flightId.utf8.count))
		
		let flightIdBytes = bytes[offset..<offset+Int(flightIdLength)]
		offset = offset.advanced(by: Int(flightIdLength))
		
		let flightIdString = String(data: Data(flightIdBytes), encoding: .utf8)
		expect(flightIdString).to(equal(flightId))
		
		let encryption = scan(UInt8.self, from: bytes, offset: &offset)
		expect(encryption).to(equal(AirMapTelemetry.Packet.EncryptionType.aes256cbc.rawValue))
		
		let ivBytes = bytes[offset..<offset+16]
		offset = offset.advanced(by: ivBytes.count)
		expect(Array(ivBytes)).to(equal(iv))
		
		let encryptedPayload = bytes[offset..<bytes.endIndex]

		// 57 byte header size
		expect(offset).to(equal(57))

		let payload = try! AES(key: key, iv: iv, blockMode: .CBC).decrypt(encryptedPayload)
		var messages = [GeneratedMessage?]()
		
		offset = payload.startIndex

		while offset < payload.count {
			
			let messageType = scan(UInt16.self, from: payload, offset: &offset).bigEndian
			let messageLength = scan(UInt16.self, from: payload, offset: &offset).bigEndian
			
			let messageData = Data(payload[offset..<offset+Int(messageLength)])
			offset = offset.advanced(by: Int(messageLength))
			
			var message: GeneratedMessage? = nil
			switch messageType {
			case ProtoBufMessage.MessageType.position.rawValue:
				message = try? Airmap.Telemetry.Position.parseFrom(data: messageData)
				expect(message).toNot(beNil())
			case ProtoBufMessage.MessageType.attitude.rawValue:
				message = try? Airmap.Telemetry.Attitude.parseFrom(data: messageData)
				expect(message).toNot(beNil())
			case ProtoBufMessage.MessageType.speed.rawValue:
				message = try? Airmap.Telemetry.Speed.parseFrom(data: messageData)
				expect(message).toNot(beNil())
			case ProtoBufMessage.MessageType.barometer.rawValue:
				message = try? Airmap.Telemetry.Barometer.parseFrom(data: messageData)
				expect(message).toNot(beNil())
			default:
				fail("unexpected type")
			}
			messages.append(message)
		}
		
		expect(messages.count).to(equal(4)); return
	}
}
	
