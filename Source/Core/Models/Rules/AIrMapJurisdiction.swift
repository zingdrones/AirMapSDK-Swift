//
//  AirMapJurisdiction.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 3/24/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class AirMapJurisdiction: Mappable, Equatable, Comparable, Hashable {
	
	public enum Region: String {
		case federal
		case state
		case county
		case city
		case local
		
		var order: Int {
			return [.federal, .state, .county, .city, .local].index(of: self)!
		}
	}
	
	public let id: Int
	public let name: String
	public let region: Region
	public let ruleSets: [AirMapRuleSet]
	
	required public init?(map: Map) {
		
		do {
			id       = try map.value("id")
			name     = try map.value("name")
			region   = try map.value("region")
			ruleSets = try map.value("rulesets")
		}
		catch let error {
			print(error)
			return nil
		}
	}
	
	public func mapping(map: Map) {}
	
	public var hashValue: Int {
		return id.hashValue
	}
	
	public var requiredRuleSets: [AirMapRuleSet] {
		return ruleSets.filter { $0.type == .required }
	}
	
	public var pickOneRuleSets: [AirMapRuleSet] {
		return ruleSets.filter { $0.type == .pickOne }
	}
	
	public var defaultPickOneRuleSet: AirMapRuleSet? {
		return pickOneRuleSets.first(where: { $0.isDefault }) ?? pickOneRuleSets.first
	}
	
	public var optionalRuleSets: [AirMapRuleSet] {
		return ruleSets.filter { $0.type == .optional }
	}
}

public func ==(lhs: AirMapJurisdiction, rhs: AirMapJurisdiction) -> Bool {
	return lhs.hashValue == rhs.hashValue
}

public func <(lhs: AirMapJurisdiction, rhs: AirMapJurisdiction) -> Bool {
	return lhs.region.order < rhs.region.order
}
