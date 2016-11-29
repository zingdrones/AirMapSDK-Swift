//
//  AirMapPilotPermitOrganization.swift
//  Pods
//
//  Created by Rocky Demoff on 11/8/16.
//
//

import ObjectMapper

@objc public class AirMapPilotPermitOrganization: NSObject {
	
	public var id = ""
	public var name = ""
	
	internal override init() {
		super.init()
	}
	
	public required init?(_ map: Map) {}
}

extension AirMapPilotPermitOrganization: Mappable {
	
	public func mapping(map: Map) {
		
		id		<-  map["id"]
		name	<-  map["name"]
	}
}
