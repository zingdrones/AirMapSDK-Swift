//
//  AirMapStatusWeather.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

@objc public class AirMapStatusWeather: NSObject {

	public var condition: String!
	public var wind: AirMapStatusWeatherWind!
	public var humidity: Float!
	public var visibility: Float!
	public var precipitation: Float!
	public var temperature: Float!
	public var icon: String!
	
	#if os(iOS) || os(tvOS) || os(watchOS)
	public lazy var iconImage: UIImage? = {
		return AirMapImage.image(named: self.icon)
	}()
	#elseif os(OSX)
	public lazy var iconImage: NSImage? = {
		return AirMapImage.image(named: self.icon)
	}()
	#endif

	public required init?(_ map: Map) {}
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
