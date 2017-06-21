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
	
	public static func getRuleSets(by ruleSetIds: [String], completion: @escaping (Result<[AirMapRuleSet]>) -> Void) {
		ruleClient.getRuleSets(by: ruleSetIds).subscribe(completion)
	}

	public static func getRuleSet(by identifier: String, completion: @escaping (Result<AirMapRuleSet>) -> Void) {
		ruleClient.getRuleSet(by: identifier).subscribe(completion)
	}

	public static func getRuleSets(intersecting geometry: AirMapGeometry, completion: @escaping (Result<[AirMapRuleSet]>) -> Void) {
		ruleClient.getRuleSets(intersecting: geometry).subscribe(completion)
	}

}
