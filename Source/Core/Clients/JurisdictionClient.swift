//
//  JurisdictionClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/5/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation
import RxSwift

internal class JurisdictionClient: HTTPClient {
	
	init() {
		super.init(basePath: Constants.AirMapApi.jurisdictionUrl)
	}
	
	enum JurisdictionClientError: Error {
		case invalidPolygon
	}
	
	func getJurisdictions(intersecting geometry: AirMapGeometry) -> Observable<[AirMapJurisdiction]> {
		AirMap.logger.debug("Getting jurisdictions intersecting geometry")
		let params = ["geometry": geometry.params()]
		return AirMap.ruleClient.perform(method: .get, path: "/", params: params)
			.map({ (rulesets: [AirMapRuleset]) -> [AirMapJurisdiction] in
				return rulesets.jurisdictions
			})
	}
	
}
