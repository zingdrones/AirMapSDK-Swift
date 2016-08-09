//
//  AirMapStatusWeatherWind.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

@objc public class AirMapStatusWeatherWind: NSObject {
	
	public var heading: Int = 0
	public var speed: Int = 0
	public var gusting: Int = 0
	
	public required init?(_ map: Map) {}
}

extension AirMapStatusWeatherWind: Mappable {
	
	public func mapping(map: Map) {
		heading  <- map["heading"]
		speed    <- map["speed"]
		gusting  <- map["gusting"]
	}
}
