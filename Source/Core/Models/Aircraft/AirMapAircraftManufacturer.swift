//
//  DroneManufacturer.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/15/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

open class AirMapAircraftManufacturer {

	open var id: String!
	open var name: String!

	required public init?(map: Map) {}
	
	internal init() {}
}

extension AirMapAircraftManufacturer: Mappable {

	public func mapping(map: Map) {
		id   <- map["id"]
		name <- map["name"]
	}
}
