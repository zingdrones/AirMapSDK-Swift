//
//  AirMap+Rules.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 1/11/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation

extension AirMap {
	
	/// Get jurisdictions and related rulesets for a given geographic area
	///
	/// - Parameters:
	///   - geometry: The area to query for jurisdictions and rulesets
	///   - completion: The handler to call with the rulesets result
	public static func getJurisdictions(intersecting geometry: AirMapGeometry, completion: @escaping (Result<[AirMapJurisdiction]>) -> Void) {
		jurisdictionClient.getJurisdictions(intersecting: geometry).thenSubscribe(completion)
	}
	
	/// Get contextual ruleset information for a given geographic area
	///
	/// - Parameters:
	///   - geometry: The area to query for rulesets
	///   - completion: The handler to call with the rulesets result
	public static func getRulesets(intersecting geometry: AirMapGeometry, completion: @escaping (Result<[AirMapRuleset]>) -> Void) {
		ruleClient.getRulesets(intersecting: geometry).thenSubscribe(completion)
	}

	/// Get detailed information for a collection of rulesets
	///
	/// - Parameters:
	///   - rulesetIds: The ruleset identifiers for which to fetch information
	///   - completion: A handler to call with the rulesets result
	public static func getRulesets(by rulesetIds: [String], completion: @escaping (Result<[AirMapRuleset]>) -> Void) {
		ruleClient.getRulesets(by: rulesetIds).thenSubscribe(completion)
	}

	/// Get detailed information for a rulesets
	///ß
	/// - Parameters:
	///   - rulesetId: The ruleset identifier for which to fetch information
	///   - completion: A handler to call with the ruleset result
	public static func getRulesets(by rulesetId: String, completion: @escaping (Result<AirMapRuleset>) -> Void) {
		ruleClient.getRuleset(by: rulesetId).thenSubscribe(completion)
	}

}
