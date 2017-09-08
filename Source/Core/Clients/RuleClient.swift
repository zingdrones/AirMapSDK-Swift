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
		super.init(basePath: Constants.AirMapApi.ruleUrl)
	}
	
	enum RulesClientError: Error {
		case invalidPolygon
	}
	
	func getJurisdictions(intersecting geometry: AirMapGeometry) -> Observable<[AirMapJurisdiction]> {
		AirMap.logger.debug("Getting jurisdictions intersecting geometry")
		let params = ["geometry": geometry.params()]
		return perform(method: .post, path: "/", params: params).map { $0.jurisdictions }
	}

	func getRuleset(by identifier: String) -> Observable<AirMapRuleset> {
		return perform(method: .get, path: "/" + identifier)
	}

	func getRulesets(intersecting geometry: AirMapGeometry) -> Observable<[AirMapRuleset]> {
		let params = ["geometry": geometry.params()]
		return perform(method: .post, path: "/", params: params)
	}
		
	func getRulesets(by rulesetIds: [String]) -> Observable<[AirMapRuleset]> {
		AirMap.logger.debug("Getting rules for ruleset:", rulesetIds)
		let params = ["rulesets": rulesetIds.joined(separator: ",")]
		return perform(method: .get, path: "/rule", params: params)
	}
	
}
