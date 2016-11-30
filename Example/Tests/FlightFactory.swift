//
//  FlightFactory.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/1/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import AirMap

class FlightFactory {

	static func defaultFlight() -> AirMapFlight {

		let flight = AirMapFlight()
		flight.flightId = "flight|1234"
		flight.pilotId = "pilot|1234"
		flight.aircraftId = "aircraft|1234"
		flight.coordinate = CLLocationCoordinate2D(latitude: 33.123456, longitude: -110.123456)
		flight.startTime = NSDate.dateFromISO8601String("2016-11-30T01:58:10.459Z")
		flight.duration = 45 * 60
		flight.isPublic = false
		flight.maxAltitude = 60.96
		flight.buffer = 150.5
		flight.notify = true
		
		return flight
	}
}
