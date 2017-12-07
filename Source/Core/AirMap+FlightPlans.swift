//
//  AirMap+FlightPlans.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/24/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation

extension AirMap {
	
	// MARK: - Flight Plans

	/// Create a new flight plan
	///
	/// - Parameters:
	///   - flightPlan: The flight plan to create
	///   - completion: A completion handler with the flight plan result
	public static func createFlightPlan(_ flightPlan: AirMapFlightPlan, completion: @escaping (Result<AirMapFlightPlan>) -> Void) {
		rx.createFlightPlan(flightPlan).thenSubscribe(completion)
	}
	
	/// Update an existing flight plan
	///
	/// - Parameters:
	///   - flightPlan: The flight plan to update
	///   - completion: A completion handler to call with the updated flight plan result
	public static func updateFlightPlan(_ flightPlan: AirMapFlightPlan, completion: @escaping (Result<AirMapFlightPlan>) -> Void) {
		rx.updateFlightPlan(flightPlan).thenSubscribe(completion)
	}
	
	/// Get a flight plan by its identifier
	///
	/// - Parameters:
	///   - flightPlanId: The identifier for the flight plan
	///   - completion: A completion handler with the flight plan result
	public static func getFlightPlan(_ flightPlanId: String, completion: @escaping (Result<AirMapFlightPlan>) -> Void) {
		rx.getFlightPlan(flightPlanId).thenSubscribe(completion)
	}
	
	/// Get a briefing for a given flight plan identifier
	///
	/// - Parameters:
	///   - flightPlanId: The identifier of the flight plan for which to retrieve a briefing
	///   - completion: A completion handler to call with the flight plan briefing result
	public static func getFlightBriefing(_ flightPlanId: String, completion: @escaping (Result<AirMapFlightBriefing>) -> Void) {
		rx.getFlightBriefing(flightPlanId).thenSubscribe(completion)
	}
	
	/// Submit a flight plan
	///
	/// - Parameters:
	///   - flightPlanId: The identifier of the flight plan to submit
	///   - completion: A completion handler to call with the flight plan result
	public static func submitFlightPlan(_ flightPlanId: String, completion: @escaping (Result<AirMapFlightPlan>) -> Void) {
		rx.submitFlightPlan(flightPlanId).thenSubscribe(completion)
	}
}
