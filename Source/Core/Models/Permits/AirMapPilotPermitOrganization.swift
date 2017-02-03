//
//  AirMapPilotPermitOrganization.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 11/8/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

open class AirMapPilotPermitOrganization {
	
	open var id = ""
	open var name = ""
	
	public required init?(map: Map) {}
}

extension AirMapPilotPermitOrganization: Mappable {
	
	public func mapping(map: Map) {
		
		id		<-  map["id"]
		name	<-  map["name"]
	}
}
