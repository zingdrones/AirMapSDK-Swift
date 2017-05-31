//
//  RuleClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 1/10/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

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
		let params: [String: Any] = [
			"geometry": geometry.params()
		]
		return perform(method: .get, path: "/", params: params)
	}
	
	func listRules(for ruleSets: [AirMapRuleSet]) -> Observable<[AirMapRule]> {
		AirMap.logger.debug("Getting rules for ruleset:", ruleSets.identifiers)
		let params = ["rulesets": ruleSets.identifiers]
		return perform(method: .get, path: "/rule", params: params)
	}	
}
