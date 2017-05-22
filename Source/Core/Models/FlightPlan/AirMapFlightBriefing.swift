//
//  AirMapFlightBriefing.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 5/21/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapFlightBriefing: Mappable {
	
	public let flightPlan: AirMapFlightPlan
	public let color: AirMapStatus.StatusColor
	public let createdAt: Date
	public let rulesets: [AirMapRuleSet]
	public let airspace: AirMapStatusAdvisory
	
	public required init?(map: Map) {
		do {
			flightPlan  = try map.value("plan")
			color       = try map.value("briefing.color")
			createdAt   = try map.value("briefing.created_at")
			rulesets    = try map.value("briefing.rulesets")
			airspace    = try map.value("briefing.airspace")
		}
		catch let error {
			print(error)
			return nil
		}
	}
	
	public func mapping(map: Map) {}
}
