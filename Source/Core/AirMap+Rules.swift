//
//  AirMap+Rules.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 1/11/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation

extension AirMap {
	
	// MARK: - Rules

	/// Get jurisdictions and related rulesets for a given geographic area
	///
	/// - Parameters:
	///   - geometry: The area to query for jurisdictions and rulesets
	///   - completion: The handler to call with the rulesets result
	public static func getJurisdictions(intersecting geometry: AirMapGeometry, completion: @escaping (Result<[AirMapJurisdiction]>) -> Void) {
		rx.getJurisdictions(intersecting: geometry).thenSubscribe(completion)
	}
	
	/// Get contextual ruleset information for a given geographic area
	///
	/// - Parameters:
	///   - geometry: The area to query for rulesets
	///   - completion: The handler to call with the rulesets result
	public static func getRulesets(intersecting geometry: AirMapGeometry, completion: @escaping (Result<[AirMapRuleset]>) -> Void) {
		rx.getRulesets(intersecting: geometry).thenSubscribe(completion)
	}

	/// Get detailed information for a collection of rulesets
	///
	/// - Parameters:
	///   - rulesetIds: The ruleset identifiers for which to fetch information
	///   - completion: A handler to call with the rulesets result
	public static func getRulesets(by rulesetIds: [AirMapRulesetId], completion: @escaping (Result<[AirMapRuleset]>) -> Void) {
		rx.getRulesets(by: rulesetIds).thenSubscribe(completion)
	}
	
	/// Get detailed information for a collection of rulesets evaluated by Flight Plan Id
	///
	/// - Parameters:
	///   - flightPlanId: The flight plan identifier for which to fetch evaluated ruleset information
	///   - completion: A handler to call with the rulesets result
	public static func getRulesetsEvaluated(by flightPlanId: AirMapFlightPlanId, completion: @escaping (Result<[AirMapFlightBriefing.Ruleset]>) -> Void) {
		rx.getRulesetsEvaluated(by: flightPlanId).thenSubscribe(completion)
	}

	/// Get rulesets evaluated for the geometry, rulesets, and flight feature values
	///
	/// - Parameters:
	///   - geometry: The geographic area to evaluate
	///   - rulesetIds: The rulesets to enable for the given area
	///   - flightFeatureValues: Additional context values for any available flight features
	///   - completion: A handler to call with the rulesets result
	public static func getRulesetsEvaluated(from geometry: AirMapGeometry, rulesetIds: [AirMapRulesetId], flightFeatureValues: [String: Any]?, completion: @escaping (Result<[AirMapFlightBriefing.Ruleset]>) -> Void) {
		rx.getRulesetsEvaluated(from: geometry, rulesetIds: rulesetIds, flightFeatureValues: flightFeatureValues).thenSubscribe(completion)
	}

	/// Get detailed information for a rulesets
	///
	/// - Parameters:
	///   - rulesetId: The ruleset identifier for which to fetch information
	///   - completion: A handler to call with the ruleset result
	public static func getRulesets(by rulesetId: AirMapRulesetId, completion: @escaping (Result<AirMapRuleset>) -> Void) {
		rx.getRuleset(by: rulesetId).thenSubscribe(completion)
	}

}
