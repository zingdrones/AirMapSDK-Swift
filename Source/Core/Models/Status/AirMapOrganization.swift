//
//  AirMapOrganization.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 11/10/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapOrganization: NSObject {

	public private(set) var id: String!
	public private(set) var name: String = ""
	
	public required init?(_ map: Map) {}
	
	override public var hashValue: Int {
		return id.hashValue
	}
}

extension AirMapOrganization: Mappable {
	
	public func mapping(map: Map) {
		id       <- map["id"]
		name     <- map["name"]
	}
}
