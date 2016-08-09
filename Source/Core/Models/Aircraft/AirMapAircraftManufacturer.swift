//
//  DroneManufacturer.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/15/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

@objc public class AirMapAircraftManufacturer: NSObject {

	public var id: String!
	public var name: String!
	public var url: String?

	internal override init() {
		super.init()
	}

	required public init?(_ map: Map) {}
}

extension AirMapAircraftManufacturer: Mappable {

	public func mapping(map: Map) {
		id   <- map["id"]
		name <- map["name"]
		url <- map["url"]
	}
}
