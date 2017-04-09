//
//  AirMapAdvisory.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 4/8/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class AirMapAdvisory: Mappable, Hashable, Equatable {
	
	public let id: String
	public let name: String
	public let lastUpdated: Date
	public let coordinate: Coordinate2D
	public let distance: Meters
	public let type: AirMapAirspaceType
	public let city: String
	public let state: String
	public let country: String
	public let ruleId: Int
	public let ruleSetId: String
	
	public required init?(map: Map) {

		do {
			id            = try map.value("id")
			name          = try map.value("name")
			lastUpdated   = try map.value("last_updated")
			distance      = try map.value("distance")
			type          = try map.value("type")
			city          = try map.value("city")
			state         = try map.value("state")
			country       = try map.value("country")
			ruleId        = try map.value("rule_id")
			ruleSetId     = try map.value("ruleset_id")

			let latitude  = try map.value("latitude") as Double
			let longitude = try map.value("longitude") as Double
			coordinate = Coordinate2D(latitude: latitude, longitude: longitude)
		}
			
		catch let error {
			print(error)
			return nil
		}
		
	}
	
	public var hashValue: Int {
		return id.hashValue
	}
	
	public func mapping(map: Map) {}
}

public func ==(lhs: AirMapAdvisory, rhs: AirMapAdvisory) -> Bool {
	return lhs.hashValue == rhs.hashValue
}
