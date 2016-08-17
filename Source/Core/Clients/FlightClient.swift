//
//  DataClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/28/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift

internal class FlightClient: HTTPClient {

	init() {
		super.init(Config.AirMapApi.flightUrl)
	}

	#if AIRMAP_TELEMETRY
	/**
	Fetches an `Comm` key for the given `AirMapFlight`
	- parameter flight: The `AirMapFlight` for which to retreive a comm key
	- returns: `Comm` key for a AirMapFlight
	*/
	func getCommKey(flight: AirMapFlight) -> Observable<Comm> {
		return call(.POST, url: "/\(flight.flightId)/start-comm")
	}

	/**
	Called when device no longer wants to recieve push notifications for traffic alerts
	- parameter flight: The `AirMapFlight` for which to retreive a comm key
	- returns: Void
	*/
	func clearCommKey(flight: AirMapFlight) -> Observable<Void> {
		return call(.POST, url: "/\(flight.flightId)/end-comm")
	}

	#endif

}

typealias FlightClient_Flight = FlightClient
extension FlightClient {

	/**
	Lists Flights

	- parameter limit: Optional, Defines the number of records returned
	- parameter pilotId: Optional, Filters flights for a particluar Pilot
	- parameter startAfter: Optional, Search for flights that start after this time
	- parameter startBefore: Optional, Search for flights that start before this time
	- parameter endAfter: Optional, Search for flights that end after this time
	- parameter endBefore: Optional, Search for flights that end before this time
	- parameter country: Optional, Search for flights within this country (Length 3, Case Insensitive)
	- parameter city: Optional, Search for flights within this city
	- parameter state: Optional, Search for flights within this state
	- parameter enhanced: Optional, Returns enhanced Flight, Pilot & Aircraft information

	- returns: `Observable<[AirMapFlight]>`

	*/
	func list(limit: Int? = nil,
	                pilotId: String? = nil,
					startAfter: NSDate? = nil,
					startBefore: NSDate? = nil,
					endAfter: NSDate? = nil,
					endBefore: NSDate? = nil,
					city: String? = nil,
					state: String? = nil,
					country: String? = nil,
					enhanced: Bool? = true,
					authCheck: Bool? = false) -> Observable<[AirMapFlight]> {

		var params = [String : AnyObject]()

		params["limit"       ] = limit
		params["pilot_id"    ] = pilotId?.isEmpty ?? true ? nil : pilotId
		params["start_after" ] = startAfter?.ISO8601String()
		params["start_before"] = startBefore?.ISO8601String()
		params["end_after"   ] = endAfter?.ISO8601String()
		params["end_before"  ] = endBefore?.ISO8601String()
		params["city"        ] = city
		params["state"       ] = state
		params["country"     ] = country
		params["enhance"     ] = String(enhanced ?? false)

		AirMap.logger.debug("Get Flights", params)
		return call(.GET, params: params, keyPath: "data.results")
	}

	func listAllPublicAndAuthenticatedPilotFlights(startBefore startBefore: NSDate = NSDate(), endAfter: NSDate = NSDate(), limit: Int? = nil) -> Observable<[AirMapFlight]> {

		AirMap.logger.debug("Get All Public and Authenticated User Flights", startBefore, endAfter)

		if AirMap.authSession.hasValidCredentials() {
			let publicFlights = list(limit, startBefore: startBefore, endAfter: endAfter)
			let pilotFlights = list(startBefore: startBefore, endAfter: endAfter, pilotId: AirMap.authSession.userId)

			return [publicFlights, pilotFlights].zip { flights in
				return Array(Set(flights.flatMap({$0})))
			}

		} else {
			return list(limit, startBefore: startBefore, endAfter: endAfter)
		}
	}

	func get(flightId: String) -> Observable<AirMapFlight> {
		AirMap.logger.debug("Get flight", flightId)
		var params = [String : AnyObject]()
		params["enhance"] = String(true)
		return call(.GET, url:"/\(flightId)", params: params)
	}

	func create(flight: AirMapFlight) -> Observable<AirMapFlight> {
		AirMap.logger.debug("Create flight", flight)
		return call(.POST, url:"/\(flight.geometryType().value)", params: flight.params(), update: flight)
	}

	func end(flight: AirMapFlight) -> Observable<AirMapFlight> {
		AirMap.logger.debug("End flight", flight)
		return call(.POST, url:"/\(flight.flightId)/end", update: flight)
	}

	func delete(flight: AirMapFlight) -> Observable<Void> {
		AirMap.logger.debug("Delete flight", flight)
		return call(.POST, url:"/\(flight.flightId)/delete")
	}
}
