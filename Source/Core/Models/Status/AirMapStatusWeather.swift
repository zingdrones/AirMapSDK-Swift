//
//  AirMapStatusWeather.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

open class AirMapStatusWeather {

	open var condition: String!
	open var wind: AirMapStatusWeatherWind!
	open var humidity: Double!
	open var visibility: Double!
	open var precipitation: Double!
	open var temperature: Celcius!
	open var icon: String!
	
	public required init?(map: Map) {}
}

extension AirMapStatusWeather: Mappable {

	public func mapping(map: Map) {
		condition     <- map["condition"]
		wind          <- map["wind"]
		humidity      <- map["humidity"]
		visibility    <- map["visibility"]
		precipitation <- map["precipitation"]
		temperature   <- map["temperature"]
		icon		  <- map["icon"]
	}
}

