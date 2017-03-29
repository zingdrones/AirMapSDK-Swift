//
//  RulesClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 1/10/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import RxSwift

internal class RulesClient: HTTPClient {
	
	init() {
		super.init(basePath: Config.AirMapApi.rulesUrl)
	}
	
	func listLocalRules(at location: Coordinate2D) -> Observable<[AirMapLocalRule]> {
		AirMap.logger.debug("GET Local Rules", location)
		let params = [
			"latitude": location.latitude,
			"longitude": location.longitude
		]
		return perform(method: .get, path: "/locale", params: params)
	}
	
}
