//
//  AirspaceClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/30/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation
import RxSwift

internal class AirspaceClient: HTTPClient {
	
	init() {
		super.init(basePath: Config.AirMapApi.airspaceUrl)
	}
	
	func getAirspace(_ airspaceId: String) -> Observable<AirMapAirspace> {
		AirMap.logger.debug("Get Airspace", airspaceId)
		return perform(method: .get, path:"/\(airspaceId)")
	}

	func listAirspace(_ airspaceIds: [String]) -> Observable<[AirMapAirspace]> {
		AirMap.logger.debug("Get Airspace", airspaceIds)
		let params = [
			"ids": airspaceIds.joined(separator: ",")
		]
		return perform(method: .get, path:"/list", params: params)
	}

}
