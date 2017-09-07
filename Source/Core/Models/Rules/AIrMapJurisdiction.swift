//
//  AirMapJurisdiction.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 3/24/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

/// An entity that has jurisdiction for generating rulesets for a given area
public struct AirMapJurisdiction {
	
	/// The unique identifier for the jurisdiction
	public let id: Int

	/// The name of the jurisdiction
	public let name: String
	
	/// The jurisdiction's region type
	public let region: Region

	/// A list rulesets available under this jurisdiction
	public let rulesets: [AirMapRuleset]
	
	/// An enumeration of the region types
	public enum Region: String {
		case federal
        case federalBackup = "federal backup"
        case federalStructureBackup = "federal structure backup"
		case state
		case county
		case city
		case local
	}
}

// MARK: - Convenience

extension AirMapJurisdiction {
	
	/// A filtered list of all the required rulesets
	public var requiredRulesets: [AirMapRuleset] {
		return rulesets.filter { $0.type == .required }
	}
	
	/// A filtered list of all pick-one rulesets
	public var pickOneRulesets: [AirMapRuleset] {
		return rulesets.filter { $0.type == .pickOne }
	}
	
	/// The default pick-one ruleset for the jurisdiction
	public var defaultPickOneRuleset: AirMapRuleset? {
		return pickOneRulesets.first(where: { $0.isDefault }) ?? pickOneRulesets.first
	}
	
	/// A filtered list of all optional rulesets
	public var optionalRulesets: [AirMapRuleset] {
		return rulesets.filter { $0.type == .optional }
	}
	
	/// A list of AirMap-recommended rulesets for the jurisdiction
	public var airMapRecommendedRulesets: [AirMapRuleset] {
		return optionalRulesets.filter { $0.shortName.uppercased() == "AIRMAP" }
	}
}
