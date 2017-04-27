//
//  AirMapOrganization.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 11/10/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapOrganization {

	public fileprivate(set) var id: String!
	public fileprivate(set) var name: String = ""
	
	public required init?(map: Map) {}
}

extension AirMapOrganization: Mappable {
	
	public func mapping(map: Map) {
		id       <- map["id"]
		name     <- map["name"]
	}
}

extension AirMapOrganization: Hashable, Equatable {
	
	static public func ==(lhs: AirMapOrganization, rhs: AirMapOrganization) -> Bool {
		return lhs.id == rhs.id
	}
	
	open var hashValue: Int {
		return id.hashValue
	}
}
