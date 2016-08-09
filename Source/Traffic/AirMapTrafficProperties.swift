//
//  AirMapTrafficProperties.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/7/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper
import CoreLocation

@objc public class AirMapTrafficProperties: NSObject {
	
	public var aircraftId: String!
	public var aircraftType: String!
	
	public override init() {
		super.init()
	}
	
	public required init?(_ map: Map) {}
}

extension AirMapTrafficProperties: Mappable {
	
	public func mapping(map: Map) {
		aircraftId   <- map["aircraft_id"]
		aircraftType <- map["aircraft_type"]
	}
}
