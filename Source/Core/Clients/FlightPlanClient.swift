//
//  FlightPlanClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 5/21/16.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import RxSwift
import ObjectMapper

internal class FlightPlanClient: HTTPClient {
	
	enum FlightPlanClientError: Error {
		case flightPlanDoesntExistCreateFirst
	}

	init() {
		super.init(basePath: Config.AirMapApi.flightPlanUrl)
	}
	
	func create(_ flightPlan: AirMapFlightPlan) -> Observable<AirMapFlightPlan> {
		AirMap.logger.debug("Create Flight Plan", flightPlan)
		return perform(method: .post, path: "/plan/", params: flightPlan.params())
	}
	
	func update(_ flightPlan: AirMapFlightPlan) -> Observable<AirMapFlightPlan> {
		AirMap.logger.debug("Update Flight Plan", flightPlan)
		guard let flightPlanId = flightPlan.id else {
			return Observable.error(FlightPlanClientError.flightPlanDoesntExistCreateFirst)
		}
		return perform(method: .patch, path: "/plan/\(flightPlanId)", params: flightPlan.params())
	}
	
	func get(_ flightPlanId: String) -> Observable<AirMapFlightPlan> {
		AirMap.logger.debug("Get Flight Plan", flightPlanId)
		return perform(method: .get, path: "/plan/\(flightPlanId)")
	}
		
	func getBriefing(_ flightPlanId: String) -> Observable<AirMapFlightBriefing> {
		return perform(method: .get, path: "/plan/\(flightPlanId)/briefing")
	}
	
	func submitFlightPlan(_ flightPlanId: String) -> Observable<AirMapFlightPlan> {
		return perform(method: .post, path: "/plan/\(flightPlanId)/submit")
	}
}
