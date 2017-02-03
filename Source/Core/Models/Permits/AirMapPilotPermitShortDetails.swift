//
//  AirMapPilotPermitShortDetails.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/28/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

open class AirMapPilotPermitShortDetails {

	open var name = ""
	open var permitDescription = ""
	open var singleUse = false
	
	public required init?(map: Map) {}
}

extension AirMapPilotPermitShortDetails: Mappable {

	public func mapping(map: Map) {

		name				<- map["name"]
		permitDescription	<- map["description"]
		singleUse			<- map["single_use"]
	}
}
