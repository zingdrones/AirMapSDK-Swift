//
//  AdvisoryClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 1/10/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation
import RxSwift

internal class AdvisoryClient: HTTPClient {
	
	init() {
		super.init(basePath: Config.AirMapApi.advisoryUrl)
	}
	
	enum AdvisoryClientError: Error {
		case invalidPolygon
	}
	
	func getAirspaceStatus(within geometry: AirMapGeometry, under ruleSets: [AirMapRuleSet]) -> Observable<AirMapAirspaceAdvisoryStatus> {
		let ruleSetIdentifiers = ruleSets.identifiers
		AirMap.logger.debug("GET Rules under", ruleSetIdentifiers)
		let geometryData = try! JSONSerialization.data(withJSONObject: geometry.geoJSONDictionary, options: [])
		let geometryJSON = String(data: geometryData, encoding: .utf8)
		let params: [String: Any] = [
			"geometry": geometryJSON ?? "",
			"rulesets": ruleSetIdentifiers
		]
		
		return perform(method: .get, path: "/airspace", params: params)
	}
}
