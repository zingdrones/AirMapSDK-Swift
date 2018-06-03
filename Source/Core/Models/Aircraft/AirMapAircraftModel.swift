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
//	public let metadata: [String: Codable]?
}

//extension AirMapAircraftModel {
//
//	enum CodingKeys: String, CodingKey {
//		case id
//		case name
//		case manufacturer
//		case metadata
//	}
//
//	public func encode(to encoder: Encoder) throws {
//		var c = encoder.container(keyedBy: CodingKeys.self)
//		try c.encode(id, forKey: .id)
//		try c.encode(name, forKey: .name)
//		try c.encode(manufacturer, forKey: .manufacturer)
//	}
//
//	public init(from decoder: Decoder) throws {
//		let v = try decoder.container(keyedBy: CodingKeys.self)
//		id = try v.decode(AirMapAircraftModelId.self, forKey: .id)
//		name = try v.decode(String.self, forKey: .name)
//		manufacturer = try v.decode(AirMapAircraftManufacturer.self, forKey: .manufacturer)
//	}
//}
