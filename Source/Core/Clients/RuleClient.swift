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
	
	func listRules(for ruleSets: [AirMapRuleSet]) -> Observable<[AirMapRule]> {
		AirMap.logger.debug("Getting rules for ruleset:", ruleSets.identifiers)
		let params = ["rulesets": ruleSets.identifiers]
		return perform(method: .get, path: "/rule", params: params)
	}
	
	func listRules(within geometry: [Coordinate2D], under ruleSets: [AirMapRuleSet]? = nil) -> Observable<[AirMapRule]> {
		AirMap.logger.debug("GET Rules", "under", geometry, "ruleSets", ruleSets ?? [])
		guard geometry.first == geometry.last else {
			return Observable.error(RulesClientError.invalidPolygon)
		}
		let polygon = geometry.flatMap {"\($0.latitude) \($0.longitude)"}.joined(separator: ", ")
		let params: [String: Any] = [
			"geometry": polygon,
			"rulesets": ruleSets ?? []
		]
		
		return perform(method: .get, path: "/rule", params: params)
	}
}
