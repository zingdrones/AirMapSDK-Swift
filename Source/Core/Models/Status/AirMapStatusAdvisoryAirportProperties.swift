//
//  AirMapStatusAdvisoryAirportProperties.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/11/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

@objc public class AirMapStatusAdvisoryAirportProperties: NSObject {

	public var identifier: String?
	public var phone: String?
	public var tower: Bool?
	public var paved: Bool?
	public var longestRunway: Int?
	public var elevation: Int?
	public var publicUse: Bool?

	public required init?(_ map: Map) {}
}

extension AirMapStatusAdvisoryAirportProperties: Mappable {

	public func mapping(map: Map) {
		identifier     <- map["identifier"]
		phone          <- map["phone"]
		tower          <- map["tower"]
		paved          <- map["paved"]
		longestRunway  <- map["longest_runway"]
		elevation      <- map["elevation"]
		publicUse      <- map["public_use"]
	}
}
