//
//  GeneratedMessage+AirMap.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 12/5/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ProtocolBuffers

typealias ProtoBufMessage = GeneratedMessage

extension ProtoBufMessage {
	
	enum MessageType: UInt16 {
		case position  = 1
		case speed     = 2
		case attitude  = 3
		case barometer = 4
	}
	
	var messageType: MessageType {
		switch self {
		case is Airmap.Telemetry.Position:
			return .position
		case is Airmap.Telemetry.Attitude:
			return .attitude
		case is Airmap.Telemetry.Speed:
			return .speed
		case is Airmap.Telemetry.Barometer:
			return .barometer
		default:
			fatalError("Unsupported Message Type")
		}
	}
	
	func telemetryBytes() -> [UInt8] {
		
		var bytes = [UInt8]()
		
		bytes += messageType.rawValue.bigEndian.bytes
		bytes += UInt16(serializedSize()).bigEndian.bytes
		bytes += data().bytes
		
		return bytes
	}
	
}
