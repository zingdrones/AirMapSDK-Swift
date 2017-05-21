//
//  FlightPlanClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 5/21/16.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import RxSwift

internal class FlightPlanClient: HTTPClient {
	
	init() {
		super.init(basePath: Config.AirMapApi.flightPlanUrl)
	}
	
	func create(_ flightPlan: AirMapFlight) -> Observable<AirMapAircraft> {
		AirMap.logger.debug("Update Aircraft", aircraft)
		let params = ["nickname": aircraft.nickname as Any]
		return perform(method: .patch, path:"/\(AirMap.authSession.userId)/aircraft/\(aircraft.id ?? "")", params: params, update: aircraft)
	}
	
	func updateAircraft(_ aircraft: AirMapAircraft) -> Observable<AirMapAircraft> {
		AirMap.logger.debug("Update Aircraft", aircraft)
		let params = ["nickname": aircraft.nickname as Any]
		return perform(method: .patch, path:"/\(AirMap.authSession.userId)/aircraft/\(aircraft.id ?? "")", params: params, update: aircraft)
	}
}
