//
//  AirMapPilotStats.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/19/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapPilotStats {
	
	public var totalAircraft = 0
	public var totalFlights = 0
	public var lastFlightTime: Date?

	public required init?(map: Map) {}
}

extension AirMapPilotStats: Mappable {
	
	public func mapping(map: Map) {
		
		let dateTransform = CustomDateFormatTransform(formatString: Config.AirMapApi.dateFormat)
		
		totalFlights   <-  map["flight.total"]
		totalAircraft  <-  map["aircraft.total"]
		lastFlightTime <- (map["flight.last_flight_time"], dateTransform)
	}
	
}
