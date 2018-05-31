//
//  AirMapJurisdiction.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 3/24/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

/// An entity that has jurisdiction for generating rulesets for a given area
public struct AirMapJurisdiction: Codable {
	
	/// The unique identifier for the jurisdiction
	public let id: AirMapJurisdictionId

	/// The name of the jurisdiction
	public let name: String
	
	/// The jurisdiction's region type
	public let region: Region

	/// A list rulesets available under this jurisdiction
	public let rulesets: [AirMapRuleset]
	
	/// An enumeration of possible region types
	public enum Region: String, Codable {
		case federal
		case state
		case county
		case city
		case local
		case federalBackup = "federal backup"
		case federalStructureBackup = "federal structure backup"
	}
}

// MARK: - Convenience

extension AirMapJurisdiction {
    
	/// Returns all rulesets which should be selected by default. This includes any required rulesets,
	/// the default pickOne if any, and any AirMap recommended rulesets
	public var defaultRulesets: [AirMapRuleset] {
		return requiredRulesets + [defaultPickOneRuleset].compactMap({$0}) + airMapRecommendedRulesets
	}
	
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

extension Sequence where Iterator.Element == AirMapJurisdiction {
	
    /// Returns all rulesets within all jurisdictions
    public var rulesets: [AirMapRuleset] {
        return flatMap({ $0.rulesets })
    }

    /// Returns all rulesets which should be selected by default. This includes any required rulesets,
	/// any default pickOnes, and any AirMap recommended rulesets
	public var defaultRulesets: [AirMapRuleset] {
		return flatMap({ $0.defaultRulesets })
	}
	
	/// Returns all required rulesets
	public var requiredRulesets: [AirMapRuleset] {
		return flatMap({ $0.requiredRulesets })
	}
	
	// Returns all optional rulesets
	public var optionalRulesets: [AirMapRuleset] {
		return flatMap({$0.optionalRulesets})
	}

	// Returns all pickOne rulesets
	public var pickOneRulesets: [AirMapRuleset] {
		return flatMap({$0.pickOneRulesets})
	}

    /// A list of AirMap-recommended rulesets for the jurisdiction
    public var airMapRecommendedRulesets: [AirMapRuleset] {
        return optionalRulesets.filter { $0.shortName.uppercased() == "AIRMAP" }
    }
}
