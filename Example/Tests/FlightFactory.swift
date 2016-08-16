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
		flight.flightId = "abcd1234"
		flight.coordinate = CLLocationCoordinate2D(latitude: 31.5, longitude: -118.0)
		flight.startTime = NSDate.dateFromISO8601String("2016-07-01T22:32:11.123Z")
		flight.isPublic = true
		flight.maxAltitude = 100
		flight.buffer = 500
		flight.notify = false

		return flight
	}
}
