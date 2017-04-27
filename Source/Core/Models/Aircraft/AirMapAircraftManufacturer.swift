//
//  AirMapAircraftManufacturer.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/15/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

final public class AirMapAircraftManufacturer: Mappable {

	public let id: String
	public let name: String

	required public init?(map: Map) {
		do {
			id   = try map.value("id")
			name = try map.value("name")
		}
		catch let error {
			AirMap.logger.error(error)
			return nil
		}
	}
	
	public func mapping(map: Map) {
		id  >>>  map["id"]
	}

}
