//
//  FlightPlanClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 5/21/16.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation
import RxSwift

internal class FlightPlanClient: HTTPClient {
	
	enum FlightPlanClientError: Error {
		case flightPlanDoesntExistCreateFirst
	}

	init() {
		super.init(basePath: Constants.AirMapApi.flightUrl)
	}
	
	func create(_ flightPlan: AirMapFlightPlan) -> Observable<AirMapFlightPlan> {
		AirMap.logger.debug("Create Flight Plan", flightPlan)
		return perform(method: .post, path: "/plan", params: flightPlan.toJSON(), update: flightPlan, checkAuth: true)
	}
	
	func update(_ flightPlan: AirMapFlightPlan) -> Observable<AirMapFlightPlan> {
		AirMap.logger.debug("Update Flight Plan", flightPlan)
		guard let flightPlanId = flightPlan.id else {
			return Observable.error(FlightPlanClientError.flightPlanDoesntExistCreateFirst)
		}
		return perform(method: .patch, path: "/plan/\(flightPlanId)", params: flightPlan.toJSON(), update: flightPlan, checkAuth: true)
	}
	
	func get(_ flightPlanId: AirMapFlightPlanId) -> Observable<AirMapFlightPlan> {
		AirMap.logger.debug("Get Flight Plan", flightPlanId)
		return perform(method: .get, path: "/plan/\(flightPlanId)", checkAuth: true)
	}
		
	func getBriefing(_ flightPlanId: AirMapFlightPlanId) -> Observable<AirMapFlightBriefing> {
		AirMap.logger.debug("Get Flight Briefing", flightPlanId)
		return perform(method: .get, path: "/plan/\(flightPlanId)/briefing", checkAuth: true)
	}
	
	func submitFlightPlan(_ flightPlanId: AirMapFlightPlanId, makeFlightPublic: Bool? = true) -> Observable<AirMapFlightPlan> {
		AirMap.logger.debug("Submit Flight Plan", flightPlanId)
		let params = ["public": makeFlightPublic as Any]
		return perform(method: .post, path: "/plan/\(flightPlanId)/submit", params: params, checkAuth: true)
	}
	
	func deleteFlightPlan(_ flightPlanId: AirMapFlightPlanId) -> Observable<Void> {
		AirMap.logger.debug("Delete Flight Plan", flightPlanId)
		return perform(method: .delete, path: "/plan/\(flightPlanId)", checkAuth: true)
	}

}
