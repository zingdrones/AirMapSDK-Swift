//
//  AirMapRule.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 4/7/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class AirMapRule: Mappable {
	
	public let id: Int
	public let description: String
	public let features: [AirMapFlightFeature]
	
	public required init?(map: Map) {
		do {
			id           = try map.value("id")
			description  = try map.value("description")
			features     = try map.value("flight_features")
		}
		catch let error {
			print(error)
			return nil
		}
	}
	
	public func mapping(map: Map) {}
}

extension AirMapRule: Hashable, Equatable {
	
	static public func ==(lhs: AirMapRule, rhs: AirMapRule) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}

	public var hashValue: Int {
		return id.hashValue
	}
}
