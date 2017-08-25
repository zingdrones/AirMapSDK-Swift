//
//  AirMap+Flights.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/28/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

public typealias AirMap_Flight = AirMap
extension AirMap_Flight {

	/// List all public flights. A user's non-public flights are excluded.
	///
	/// - Parameters:
	///   - fromDate: The start of search window. Optional
	///   - toDate: The end of search window. Optional
	///   - limit: The maximum number of flights to return. Optional
	///   - completion: A completion handler to call with the Result
	public static func listPublicFlights(from fromDate: Date? = nil, to toDate: Date? = nil, limit: Int? = nil, completion: @escaping (Result<[AirMapFlight]>) -> Void) {
		flightClient.listPublicFlights(from: fromDate, to: toDate, limit: limit).thenSubscribe(completion)
	}

	/// List all flights belonging only to the currently authenticated pilot
	///
	/// - Parameters:
	///   - pilot: The pilot for which to return flights
	///   - limit: The maximum number of flights to return. Optional
	///   - completion: A completion handler to call with the Result
	public static func listFlights(for pilot: AirMapPilot, limit: Int? = 100, completion: @escaping (Result<[AirMapFlight]>) -> Void) {
		flightClient.list(limit: limit, pilotId: pilot.id).thenSubscribe(completion)
	}
	
	/// Get the current flight belonging to the currently authenticated pilot
	///
	/// - Parameter completion: A completion handler to call with the Result
	public static func getCurrentAuthenticatedPilotFlight(_ completion: @escaping (Result<AirMapFlight?>) -> Void) {
		flightClient.list(pilotId: AirMap.authSession.userId, startBeforeNow: true, endAfterNow: true, enhanced: true, checkAuth: true).map { $0.first }.thenSubscribe(completion)
	}

	/// Get a flight by its identifer
	///
	/// - Parameters:
	///   - flightId: The unique identifier associated with the flight
	///   - completion: A completion handler to call with the Result
	public static func getFlight(_ flightId: String, completion: @escaping (Result<AirMapFlight>) -> Void) {
		flightClient.get(flightId).thenSubscribe(completion)
	}

	/// Create a new flight for the currently authenticated pilot
	///
	/// - Parameters:
	///   - flight: The flight to create
	///   - completion: A completion handler to call with the Result
	public static func createFlight(_ flight: AirMapFlight, completion: @escaping (Result<AirMapFlight>) -> Void) {
		flightClient.create(flight).thenSubscribe(completion)
	}

	/// End a flight, setting its `endTime` to now
	///
	/// - Parameters:
	///   - flight: The flight to end
	///   - completion: A completion handler to call with the Result
	public static func endFlight(_ flight: AirMapFlight, completion: @escaping (Result<AirMapFlight>) -> Void) {
		flightClient.end(flight).thenSubscribe(completion)
	}

	/// Delete a flight
	///
	/// - Parameters:
	///   - flight: The flight to delete
	///   - completion: A completion handler to call with the Result
	public static func deleteFlight(_ flight: AirMapFlight, completion: @escaping (Result<Void>) -> Void) {
		flightClient.delete(flight).thenSubscribe(completion)
	}
	
	/// Get a flight plan by flight id
	///
	/// - Parameters:
	///   - id: The identifier for the flight
	///   - completion: A completion handler with the flight plan result
	public static func getFlightPlanByFlightId(_ id: String, completion: @escaping (Result<AirMapFlightPlan>) -> Void) {
		flightClient.getFlightPlanByFlightId(id).thenSubscribe(completion)
	}
}
