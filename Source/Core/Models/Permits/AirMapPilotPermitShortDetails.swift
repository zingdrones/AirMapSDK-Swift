//
//  AirMapPilotPermitShortDetails.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/28/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

@objc public class AirMapPilotPermitShortDetails: NSObject {

	public var name = ""
	public var singleUse = false

	internal override init() {
		super.init()
	}
	
	public required init?(_ map: Map) {}
}

extension AirMapPilotPermitShortDetails: Mappable {

	public func mapping(map: Map) {

		name		<-  map["name"]
		singleUse	<-  map["single_use"]
	}
}
