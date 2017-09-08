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
	
	/// An enumeration of possible region types
	public enum Region: String {
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
		return requiredRulesets + [defaultPickOneRuleset].flatMap({$0}) + airMapRecommendedRulesets
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

extension AirMapJurisdiction {
	
	/// Take the user's rulesets preference and resolve which rulesets should be selected from the available jurisdictions
	///
	/// - Parameters:
	///   - preferredRulesetIds: An array of rulesets ids the user has previously selected
	///   - availableJurisdictions: An array of relevant jurisdictions for the area of operation
	/// - Returns: A resolved array of rulesets taking into account the user's selection preference
	public static func resolvedRulesets(with preferredRulesetIds: [String], from availableJurisdictions: [AirMapJurisdiction]) -> [AirMapRuleset] {
		
		var rulesets = [AirMapRuleset]()
		
		// Always include the required rulesets
		rulesets += availableJurisdictions.requiredRulesets
		
		// If the preferred rulesets contains an optional ruleset, add it to the array
		rulesets += availableJurisdictions.optionalRulesets.filter({ preferredRulesetIds.contains($0.id) })
		
		// For each jurisdiction, determine a preferred pickOne has been set otherwise take the default pickOne
		for jurisdiction in availableJurisdictions {
			guard let defaultPickOneRuleset = jurisdiction.defaultPickOneRuleset else { continue }
			if let preferredPickOne = jurisdiction.pickOneRulesets.first(where: { preferredRulesetIds.contains($0.id) }) {
				rulesets.append(preferredPickOne)
			} else {
				rulesets.append(defaultPickOneRuleset)
			}
		}
		
		return rulesets
	}

}

extension Sequence where Iterator.Element == AirMapJurisdiction {
	
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
}
