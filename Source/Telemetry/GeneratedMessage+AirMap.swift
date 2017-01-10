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
		case Position  = 0
		case Speed     = 1
		case Attitude  = 2
		case Barometer = 3
	}
	
	var messageType: MessageType {
		switch self {
		case is Airmap.Telemetry.Position:
			return .Position
		case is Airmap.Telemetry.Attitude:
			return .Attitude
		case is Airmap.Telemetry.Speed:
			return .Speed
		case is Airmap.Telemetry.Barometer:
			return .Barometer
		default:
			fatalError("Unsupported Message Type")
		}
	}
	
	func telemetryData() -> NSData {
		let payloadData = self.data()
		let telemetryData = NSMutableData()
		telemetryData.appendData(messageType.rawValue.data)
		telemetryData.appendData(UInt16(payloadData.length).data)
		telemetryData.appendData(payloadData)
		return telemetryData
	}
}
