//
//  AirMapDrone.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/15/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

final public class AirMapAircraftModel: Mappable {
	
	public let modelId: String
	public let name: String
	public let manufacturer: AirMapAircraftManufacturer
	public let metadata: [String: AnyObject]?
	
	public required init?(map: Map) {
		do {
			modelId      = try  map.value("id")
			name         = try  map.value("name")
			manufacturer = try  map.value("manufacturer")
			metadata     = try? map.value("metadata")
		}
		catch let error {
			AirMap.logger.error(error)
			return nil
		}
	}
}

extension AirMapAircraftModel {
	
	public func mapping(map: Map) {
		modelId  >>>  map["id"]
	}
}
