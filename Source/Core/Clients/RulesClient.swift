//
//  RulesClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 1/10/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import CoreLocation
import RxSwift

internal class RulesClient: HTTPClient {
	
	init() {
		super.init(Config.AirMapApi.rulesUrl)
	}
	
	func getLocalRules(location: CLLocationCoordinate2D) -> Observable<[AirMapLocalRule]> {
		AirMap.logger.debug("GET Local Rules", location)
		let params = [
			"latitude": location.latitude,
			"longitude": location.longitude
		]
		return call(.GET, url: "/local", params: params, keyPath: "data.results")
	}
	
}
