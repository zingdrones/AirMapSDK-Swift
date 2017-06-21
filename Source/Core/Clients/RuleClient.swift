//
//  RuleClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 1/10/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation
import RxSwift

internal class RuleClient: HTTPClient {
	
	init() {
		super.init(basePath: Config.AirMapApi.ruleUrl)
	}
	
	enum RulesClientError: Error {
		case invalidPolygon
	}
	
	func getRuleSet(by identifier: String) -> Observable<AirMapRuleSet> {
		return perform(method: .get, path: "/" + identifier)
	}

	func getRuleSets(intersecting geometry: AirMapGeometry) -> Observable<[AirMapRuleSet]> {
		let geometryData = try! JSONSerialization.data(withJSONObject: geometry.params(), options: [])
		let geometryJSON = String(data: geometryData, encoding: .utf8)
		let params: [String: Any] = [
			"geometry": geometryJSON ?? ""
		]
		return perform(method: .get, path: "/", params: params)
			// FIXME: Removing AMD airspace
			.map({ (ruleSets: [AirMapRuleSet]) -> [AirMapRuleSet] in
				ruleSets.filter { $0.shortName != "AMD"}
			})
	}
		
	func getRuleSets(by ruleSetIds: [String]) -> Observable<[AirMapRuleSet]> {
		AirMap.logger.debug("Getting rules for ruleset:", ruleSetIds)
		let params = ["rulesets": ruleSetIds.joined(separator: ",")]
		return perform(method: .get, path: "/rule", params: params)
	}	
}

