//
//  AirMapFlightBriefing.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 5/21/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapFlightBriefing: Mappable {
	
	public let createdAt: Date
	public let rulesets: [AirMapFlightBriefingRuleset]
	public let airspace: AirMapAirspaceAdvisoryStatus
	
	public required init?(map: Map) {
		do {
			createdAt   = (try? map.value("created_at")) ?? Date()
			rulesets    =  try  map.value("rulesets")
			airspace    =  try  map.value("airspace")
		}
		catch let error {
			print(error)
			return nil
		}
	}
	
	public func mapping(map: Map) {}
}

public class AirMapFlightBriefingRuleset: Mappable {
	
	public let id: String
	public let rules: [AirMapRule]
	
	public required init?(map: Map) {
		do {
			id    = try map.value("id")
			rules = try map.value("rules")
		}
		catch let error {
			print(error)
			return nil
		}
	}
	
	public func mapping(map: Map) {}
	
}
