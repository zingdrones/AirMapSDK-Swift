//
//  AirMapRule.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 4/7/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapRule: Mappable {
	
	public enum Status: String {
		case unevaluated
		case conflicting
		case notConflicting = "not_conflicting"
		case missingInfo = "missing_info"
//		case informational
	}
	
	public let id: Int
	public let shortText: String
	public let description: String
	public let status: Status
	
	public required init?(map: Map) {
		do {
			id           =  try  map.value("id")
			shortText    =  try  map.value("short_text")
			description  =  try  map.value("description")
			status       = (try? map.value("status")) ?? .unevaluated
		}
		catch let error {
			print(error)
			return nil
		}
	}
	
	public func mapping(map: Map) {}
}

extension AirMapRule: Hashable, Equatable {
	
	static public func ==(lhs: AirMapRule, rhs: AirMapRule) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}

	public var hashValue: Int {
		return id.hashValue
	}
}
