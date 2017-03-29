//
//  AirMapLocalRule.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 1/10/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapLocalRule: Hashable, Equatable {
	
	public var id = String()
	public var jurisdictionName = String()
	public var jurisdictionType = String()
	public var text = String()
	public var summary: String?
	public var lastUpdated = Date()
	public var url: URL?
	
	public required init?(map: Map) {}
	
	public var hashValue: Int {
		return id.hashValue
	}
}

extension AirMapLocalRule: Mappable {
	
	public func mapping(map: Map) {
		id                <-  map["id"]
		jurisdictionName  <-  map["jurisdiction_name"]
		jurisdictionType  <-  map["jurisdiction_type"]
		text              <-  map["text"]
		summary           <-  map["summary"]
		url               <- (map["url"], URLTransform())
		lastUpdated       <-  map["last_updated"]
	}
}

public func ==(lhs: AirMapLocalRule, rhs: AirMapLocalRule) -> Bool {
	return lhs.id == rhs.id
}
