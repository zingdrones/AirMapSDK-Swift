//
//  AirMapRule.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 1/10/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapLocalRule: NSObject {
	
	var id = String()
	var jurisdictionName = String()
	var jurisdictionType = String()
	var text = String()
	var summary: String?
	var lastUpdated = NSDate()
	var url: NSURL?
	
	public required init?(_ map: Map) {}
	public override init() { super.init() }
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

func ==(lhs: AirMapLocalRule, rhs: AirMapLocalRule) -> Bool {
	return lhs.id == rhs.id
}
