//
//  AirMapFlightBriefing.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 5/21/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapFlightBriefing: Mappable {
	
	public let color: AirMapStatus.StatusColor
	public let createdAt: Date
	public let rulesets: [AirMapRuleSet]
	public let airspace: AirMapStatusAdvisory
	
	public required init?(map: Map) {
		do {
			color       = try map.value("color")
			createdAt   = try map.value("created_at")
			rulesets    = try map.value("rulesets")
			airspace    = try map.value("airspace")
		}
		catch let error {
			print(error)
			return nil
		}
	}
	
	public func mapping(map: Map) {}
}
