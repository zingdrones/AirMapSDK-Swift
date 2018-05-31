//
//  AirMapDrone.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/15/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

public struct AirMapAircraftModel: Codable {
	
	public let id: AirMapAircraftModelId
	public let name: String
	public let manufacturer: AirMapAircraftManufacturer
	public let metadata: [String: AnyObject]?
}

extension AirMapAircraftModel {

	public func encode(to encoder: Encoder) throws {
		// FIXME:
		fatalError()
	}

	public init(from decoder: Decoder) throws {
		// FIXME:
		fatalError()
	}
}
