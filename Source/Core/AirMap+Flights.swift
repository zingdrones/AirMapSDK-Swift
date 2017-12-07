//
//  AirMap+Flights.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/28/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

extension AirMap {

	// MARK: - Flights

	/// List all public flights. A user's non-public flights are excluded.
	///
	/// - Parameters:
	///   - fromDate: The start of search window. Optional
	///   - toDate: The end of search window. Optional
	///   - limit: The maximum number of flights to return. Optional
	///   - completion: A completion handler to call with the Result
	public static func listPublicFlights(from fromDate: Date? = nil, to toDate: Date? = nil, limit: Int? = nil, completion: @escaping (Result<[AirMapFlight]>) -> Void) {
		rx.listPublicFlights(from: fromDate, to: toDate, limit: limit).thenSubscribe(completion)
	}

	/// List all flights belonging only to the currently authenticated pilot
	///
	/// - Parameters:
	///   - pilotId: The pilot identifier for which to return flights
	///   - limit: The maximum number of flights to return. Optional
	///   - completion: A completion handler to call with the Result
	public static func listFlights(for pilotId: String, limit: Int? = 100, completion: @escaping (Result<[AirMapFlight]>) -> Void) {
		rx.listFlights(for: pilotId, limit: limit).thenSubscribe(completion)
	}
	
	/// Get the current flight belonging to the currently authenticated pilot
	///
	/// - Parameter completion: A completion handler to call with the Result
	public static func getCurrentAuthenticatedPilotFlight(_ completion: @escaping (Result<AirMapFlight?>) -> Void) {
		rx.getCurrentAuthenticatedPilotFlight().thenSubscribe(completion)
	}

	/// Get a flight by its identifer
	///
	/// - Parameters:
	///   - id: The unique identifier associated with the flight
	///   - completion: A completion handler to call with the Result
	public static func getFlight(by id: String, completion: @escaping (Result<AirMapFlight>) -> Void) {
		rx.getFlight(by: id).thenSubscribe(completion)
	}

	/// Create a new flight for the currently authenticated pilot
	///
	/// - Parameters:
	///   - flight: The flight to create
	///   - completion: A completion handler to call with the Result
	public static func createFlight(_ flight: AirMapFlight, completion: @escaping (Result<AirMapFlight>) -> Void) {
		rx.createFlight(flight).thenSubscribe(completion)
	}

	/// End a flight, setting its `endTime` to now
	///
	/// - Parameters:
	///   - flight: The flight to end
	///   - completion: A completion handler to call with the Result
	public static func endFlight(_ flight: AirMapFlight, completion: @escaping (Result<AirMapFlight>) -> Void) {
		rx.endFlight(flight).thenSubscribe(completion)
	}
	
	/// End a flight, setting its `endTime` to now
	///
	/// - Parameters:
	///   - id: The unique identifier associated with the flight
	///   - completion: A completion handler to call with the Result
	public static func endFlight(by id: String, completion: @escaping (Result<Void>) -> Void) {
		rx.endFlight(by: id).thenSubscribe(completion)
	}

	/// Delete a flight
	///
	/// - Parameters:
	///   - flight: The flight to delete
	///   - completion: A completion handler to call with the Result
	public static func deleteFlight(_ flight: AirMapFlight, completion: @escaping (Result<Void>) -> Void) {
		rx.deleteFlight(flight).thenSubscribe(completion)
	}
	
	/// Get a flight plan by flight id
	///
	/// - Parameters:
	///   - id: The identifier for the flight
	///   - completion: A completion handler with the flight plan result
	public static func getFlightPlanByFlightId(_ id: String, completion: @escaping (Result<AirMapFlightPlan>) -> Void) {
		rx.getFlightPlanByFlightId(id).thenSubscribe(completion)
	}
}
