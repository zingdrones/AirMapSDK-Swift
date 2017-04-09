//
//  AirMapFlightFeature.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 4/8/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapFlightFeature: Mappable, Equatable, Hashable {
	
	public let id: Int
	public let feature: String
	public let description: String
	public let type: String
	
	public required init?(map: Map) {

		do {
			id          = try map.value("id")
			feature     = try map.value("feature")
			description = try map.value("description")
			type        = try map.value("type")
		}
		
		catch let error {
			print(error)
			return nil
		}
	}
	
	public func mapping(map: Map) {}
	
	public var hashValue: Int {
		return id.hashValue
	}
}

public func ==(lhs: AirMapFlightFeature, rhs: AirMapFlightFeature) -> Bool {
	return lhs.hashValue == rhs.hashValue
}
