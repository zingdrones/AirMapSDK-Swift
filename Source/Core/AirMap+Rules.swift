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
	
	/// List the airspace rules for a given area, optionally providing the rulesets under which a flight shall be conducted
	///
	/// - Parameters:
	///   - ruleSets: Array of rule sets
	///   - completion: Completion handler
	public static func listRules(for ruleSets: [AirMapRuleSet], completion: @escaping (Result<[AirMapRule]>) -> Void) {
		ruleClient.listRules(for: ruleSets).subscribe(completion)
	}

	public static func getRuleSet(by identifier: String, completion: @escaping (Result<AirMapRuleSet>) -> Void) {
		ruleClient.getRuleSet(by: identifier).subscribe(completion)
	}

}
