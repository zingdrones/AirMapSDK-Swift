//
//  AirMapPilotStats.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/19/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public struct AirMapPilotStats: Codable {
	
	public let totalAircraft: Int
	public let totalFlights: Int
	public let lastFlightTime: Date?
}

extension AirMapPilotStats: ImmutableMappable {
	
	public init(map: Map) throws {
		totalFlights    =  try map.value("flight.total")
		totalAircraft   =  try map.value("aircraft.total")
		lastFlightTime  =  try? map.value("flight.last_flight_time", using: Constants.AirMapApi.dateTransform)
	}
	
}
