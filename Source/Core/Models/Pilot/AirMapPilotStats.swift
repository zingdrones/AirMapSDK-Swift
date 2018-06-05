//
//  AirMapPilotStats.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/19/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

public struct AirMapPilotStats: Codable {
	public let totalAircraft: Int
	public let totalFlights: Int
	public let lastFlightTime: Date?
}
