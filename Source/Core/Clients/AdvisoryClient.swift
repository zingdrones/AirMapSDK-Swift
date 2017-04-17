//
//  AdvisoryClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 1/10/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import RxSwift

internal class AdvisoryClient: HTTPClient {
	
	init() {
		super.init(basePath: Config.AirMapApi.advisoryUrl)
	}
	
	enum AdvisoryClientError: Error {
		case invalidPolygon
	}
	
	func getAirspaceStatus(within polygon: [Coordinate2D], under ruleSets: [AirMapRuleSet]? = nil) -> Observable<AirMapAirspaceAdvisoryStatus> {
		let ruleSetIdentifiers = (ruleSets ?? []).identifiers
		AirMap.logger.debug("GET Rules under", ruleSetIdentifiers)
		guard polygon.count >= 3, polygon.first == polygon.last else {
			return Observable.error(AdvisoryClientError.invalidPolygon)
		}
		let polygon = polygon.flatMap {"\($0.longitude) \($0.latitude)"}.joined(separator: ", ")
		let params: [String: Any] = [
			"geometry": "POLYGON(\(polygon))",
			"rulesets": ruleSetIdentifiers
		]
		
		return perform(method: .get, path: "/airspace", params: params)
	}
}

