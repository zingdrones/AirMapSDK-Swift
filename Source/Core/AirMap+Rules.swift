//
//  AirMap+Rules.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 1/11/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation

public typealias AirMap_Rules = AirMap
extension AirMap_Rules {
	
	/// Get contextual ruleset information for a given geographic area
	///
	/// - Parameters:
	///   - geometry: The area to query for rulesets
	///   - completion: The handler to call with the rulesets result
	public static func getRuleSets(intersecting geometry: AirMapGeometry, completion: @escaping (Result<[AirMapRuleSet]>) -> Void) {
		ruleClient.getRuleSets(intersecting: geometry).thenSubscribe(completion)
	}

	/// Get detailed information for a collection of rulesets
	///
	/// - Parameters:
	///   - ruleSetIds: The ruleset identifiers for which to fetch information
	///   - completion: A handler to call with the rulesets result
	public static func getRuleSets(by ruleSetIds: [String], completion: @escaping (Result<[AirMapRuleSet]>) -> Void) {
		ruleClient.getRuleSets(by: ruleSetIds).thenSubscribe(completion)
	}

	/// Get detailed information for a rulesets
	///
	/// - Parameters:
	///   - ruleSetId: The ruleset identifier for which to fetch information
	///   - completion: A handler to call with the ruleset result
	public static func getRuleSets(by ruleSetId: String, completion: @escaping (Result<AirMapRuleSet>) -> Void) {
		ruleClient.getRuleSet(by: ruleSetId).thenSubscribe(completion)
	}

}
