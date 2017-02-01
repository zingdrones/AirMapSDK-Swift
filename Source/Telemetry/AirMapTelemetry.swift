//
//  AirMapTelemetry.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 12/5/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import CoreLocation
import CryptoSwift
import ProtocolBuffers
import CocoaAsyncSocket
import RxSwift

struct AirMapTelemetry {
	
	static let serialQueue = dispatch_queue_create("com.airmap.serialqueue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, 0))
	
	class Client {
		
		func sendTelemetry(flight: AirMapFlight, message: ProtoBufMessage) {
			telemetry.onNext((flight, message))
		}
		
		private let telemetry = PublishSubject<(flight: AirMapFlight, message: ProtoBufMessage)>()
		private let disposeBag = DisposeBag()
		
		init() {
			setupBindings()
		}
		
		private func setupBindings() {

			// TODO: setup background serial queue
			let scheduler = MainScheduler.asyncInstance
			
			let session = telemetry
				.map { $0.flight }
				.distinctUntilChanged()
				.flatMap { flight in
					AirMap.flightClient
						.getCommKey(flight)
						.map { Session(flight: flight, commKey: $0) }
				}
			
			let flightMessages = Observable
				.combineLatest(session, telemetry) { $0 }
				.filter { flightSession, telemetry in
					telemetry.flight == flightSession.flight
				}
				.map { (session: Session, telemetry: (flight: AirMapFlight, message: ProtoBufMessage)) in
					(session: session, message: telemetry.message)
			}
			
			let frequency = Config.AirMapTelemetry.SampleFrequency.self
			
			let position = flightMessages
				.filter { $0.1 is Airmap.Telemetry.Position }
				.sample(Observable<Int>.timer(0, period: frequency.position, scheduler: scheduler))
			
			let attitude = flightMessages
				.filter { $0.1 is Airmap.Telemetry.Attitude }
				.sample(Observable<Int>.timer(0, period: frequency.attitude, scheduler: scheduler))
			
			let speed = flightMessages
				.filter { $0.1 is Airmap.Telemetry.Speed }
				.sample(Observable<Int>.timer(0, period: frequency.speed, scheduler: scheduler))
			
			let barometer = flightMessages
				.filter { $0.1 is Airmap.Telemetry.Barometer }
				.sample(Observable<Int>.timer(0, period: frequency.barometer, scheduler: scheduler))
			
			let latestMessages = [position, speed, barometer].toObservable().merge()
				.buffer(timeSpan: 1, count: 20, scheduler: scheduler)
				.subscribeNext(Client.sendMessages)
				.addDisposableTo(disposeBag)
		}
		
		private static func sendMessages(telemetry: [(session: Session, message: ProtoBufMessage)]) {
            
            guard telemetry.count > 0 else {
                return
            }
            
			let session = telemetry.first!.session
			let messages = telemetry.map { $0.message }
			session.send(messages)
		}
		
	}
	
	class Session {
		
		let flight: AirMapFlight
		let commKey: CommKey
		
		static var socket = Socket(socketQueue: serialQueue)
		
		private let encryption = Packet.EncryptionType.AES256CBC
		private var serialNumber: UInt32 = 0
				
		init(flight: AirMapFlight, commKey: CommKey) {
			self.flight = flight
			self.commKey = commKey
		}
		
		func send(messages: [ProtoBufMessage]) {

			let payload = messages.map { msg in msg.telemetryData() }.data()
			let packet: Packet
			let serial = nextPacketId()
			let flightId = flight.flightId
			
			switch encryption {
			case .AES256CBC:
				let iv = AirMapTelemetry.generateIV()
				let encryptedPayload = payload.AES256CBCEncrypt(key: commKey.binaryKey(), iv: iv)!
				packet = Packet(
					serial: serial, flightId: flightId, payload: encryptedPayload,
					encryption: encryption, encryptionData: NSData(bytes: iv)
				)
			case .None:
				packet = Packet(
					serial: serial, flightId: flightId, payload: payload,
					encryption: encryption, encryptionData: NSData()
				)
			}

			Session.socket.sendData(packet.data())
		}
		
		private func nextPacketId() -> UInt32 {
			dispatch_sync(serialQueue) {
				serialNumber += 1
			}
			return serialNumber
		}
	}

	class Socket: GCDAsyncUdpSocket {
		
		var host = Config.AirMapTelemetry.host
		var port = Config.AirMapTelemetry.port

		func sendData(data: NSData) {
			sendData(data, toHost: host, port: port, withTimeout: 15, tag: 0)
		}
	}
	
	struct Packet {
		
		enum EncryptionType: UInt8 {
			case None = 0 // Unsupported by backend; for testing only
			case AES256CBC = 1
		}

		let serial: UInt32
		let flightId: String
		let payload: NSData
		let encryption: EncryptionType
		let encryptionData: NSData
		
		func data() -> NSData {
			
			let id = flightId.dataUsingEncoding(NSUTF8StringEncoding)!
			let header = NSMutableData()
			header.appendData(serial.data)
			header.appendData(UInt8(id.length).data)
			header.appendData(id)
			header.appendData(encryption.rawValue.data)
			
			switch encryption {
			case .AES256CBC:
				assert(encryptionData.length == 16)
				header.appendData(encryptionData)
			case .None:
				break
			}
			
			return [header, payload].data()
		}
	}
	
	static func generateIV() -> [UInt8] {
		return AES.randomIV(AES.blockSize)
	}
	
}
