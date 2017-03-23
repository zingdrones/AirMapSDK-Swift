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
	
	static let serialQueue = DispatchQueue(label: "com.airmap.serialqueue", qos: .utility, attributes: DispatchQueue.Attributes(), autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit)
	
	class Client {
		
		func sendTelemetry(_ flight: AirMapFlight, message: ProtoBufMessage) {
			telemetry.onNext((flight, message))
		}
		
		fileprivate let telemetry = PublishSubject<(flight: AirMapFlight, message: ProtoBufMessage)>()
		fileprivate let disposeBag = DisposeBag()
		
		init() {
			setupBindings()
		}
		
		fileprivate func setupBindings() {

			// TODO: setup background serial queue
			let scheduler = MainScheduler.asyncInstance
			
			let session = telemetry
				.map { $0.flight }
				.distinctUntilChanged()
				.flatMap { flight in
					AirMap.flightClient
						.getCommKey(flight: flight)
						.map { Session(flight: flight, commKey: $0) }
				}
			
			let flightMessages = Observable
				.combineLatest(session, telemetry) { $0 }
				.share()
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
			
			Observable.from([position, attitude, speed, barometer]).merge()
				.buffer(timeSpan: 1, count: 20, scheduler: scheduler)
				.do(onNext: Client.sendMessages)
				.subscribe()
				.disposed(by: disposeBag)
		}
		
		fileprivate static func sendMessages(_ telemetry: [(session: Session, message: ProtoBufMessage)]) {
            
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
		
		fileprivate let encryption = Packet.EncryptionType.aes256cbc
		fileprivate var serialNumber: UInt32 = 0
				
		init(flight: AirMapFlight, commKey: CommKey) {
			self.flight = flight
			self.commKey = commKey
		}
		
		func send(_ messages: [ProtoBufMessage]) {

			let payload = messages.flatMap { msg in msg.telemetryBytes() }
			let packet: Packet
			let serial = nextPacketId()
			guard let flightId = flight.flightId else { return }
			
			switch encryption {
			case .aes256cbc:
				let iv = AirMapTelemetry.generateIV()
				let key = commKey.bytes()
				let encryptedPayload = try! AES(key: key, iv: iv, blockMode: .CBC).encrypt(payload)

				packet = Packet(
					serial: serial, flightId: flightId, payload: encryptedPayload,
					encryption: encryption, iv: iv
				)
			case .none:
				packet = Packet(
					serial: serial, flightId: flightId, payload: payload,
					encryption: encryption, iv: []
				)
			}

			let data = Data(bytes: packet.bytes())
			Session.socket.sendData(data)
		}
		
		fileprivate func nextPacketId() -> UInt32 {
			serialQueue.sync {
				serialNumber += 1
			}
			return serialNumber
		}
	}

	class Socket: GCDAsyncUdpSocket {
		
		var host = Config.AirMapTelemetry.host
		var port = Config.AirMapTelemetry.port

		func sendData(_ data: Data) {
			send(data, toHost: host, port: port, withTimeout: 15, tag: 0)
		}
	}
	
	struct Packet {
		
		enum EncryptionType: UInt8 {
			case none = 0 // Unsupported by backend; for testing only
			case aes256cbc = 1
		}

		let serial: UInt32
		let flightId: String
		let payload: [UInt8]
		let encryption: EncryptionType
		let iv: [UInt8]
		
		func bytes() -> [UInt8] {
			
			let id = flightId.data(using: .utf8)!.bytes
			var header = [UInt8]()
			header += serial.bigEndian.bytes
			header += UInt8(id.count).bytes
			header += id
			header += encryption.rawValue.bytes
			
			switch encryption {
			case .aes256cbc:
				assert(iv.count == 16)
				header += iv
			case .none:
				break
			}
			
			return header + payload
		}
	}
	
	static func generateIV() -> [UInt8] {
		
		return AES.randomIV(AES.blockSize)
	}
	
}
