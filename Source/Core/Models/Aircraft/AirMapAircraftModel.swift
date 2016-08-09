//
//  AirMapDrone.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/15/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

@objc public class AirMapAircraftModel: NSObject {

	public var modelId: String!
	public var name: String!
	public var manufacturer: AirMapAircraftManufacturer!
	public var metadata = [String : AnyObject]()

	internal override init() {
		super.init()
	}
	
	public required init?(_ map: Map) {}
}

extension AirMapAircraftModel: Mappable {

	public func mapping(map: Map) {
		modelId       <-  map["id"]
		name          <-  map["name"]
		manufacturer  <-  map["manufacturer"]
		metadata      <-  map["metadata"]
	}
}
