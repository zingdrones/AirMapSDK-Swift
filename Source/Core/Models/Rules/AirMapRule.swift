//
//  AirMapRule.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 4/7/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapRule: Mappable {
	
	public enum Status: String {
		case conflicting
		case missingInfo = "missing_info"
		case informational
		case notConflicting = "not_conflicting"
		case unevaluated
	}
	
	public let description: String
	public let shortText: String?
	public let status: Status
	public let flightFeatures: [AirMapFlightFeature]
	public let displayOrder: Int
	
	public required init?(map: Map) {
		do {
			shortText      =  try? map.value("short_text")
			description    =  try  map.value("description")
			flightFeatures = (try? map.value("flight_features")) ?? []
			status         = (try? map.value("status")) ?? .unevaluated
			displayOrder   = (try? map.value("display_order")) ?? Int.max
		}
		catch let error {
			print(error)
			return nil
		}
	}
	
	public func mapping(map: Map) {}
}

extension AirMapRule.Status: Comparable {
	
	var order: Int {
		return [.conflicting, .missingInfo, .informational, .notConflicting, .unevaluated].index(of: self)!
	}
	
	public static func <(lhs: AirMapRule.Status, rhs: AirMapRule.Status) -> Bool {
		return lhs.order < rhs.order
	}
}
