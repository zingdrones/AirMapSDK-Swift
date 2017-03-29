//
//  AirMapDrone.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/15/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapAircraftModel {

	open var modelId: String!
	open var name: String!
	open var manufacturer: AirMapAircraftManufacturer!
	open var metadata = [String : AnyObject]()
	
	public required init?(map: Map) {}
	
	internal init() {}
}

extension AirMapAircraftModel: Mappable {

	public func mapping(map: Map) {
		modelId       <-  map["id"]
		name          <-  map["name"]
		manufacturer  <-  map["manufacturer"]
		metadata      <-  map["metadata"]
	}
}
