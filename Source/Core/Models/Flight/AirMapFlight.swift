//
//  AirMapFlight.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 4/18/16.
/*
Copyright 2018 AirMap, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
//

import Foundation
import ObjectMapper

public enum AirMapFlightGeometryType: String {
	case point
	case path
	case polygon
}

public class AirMapFlight {
	
    public var id: AirMapFlightId?
	public var flightPlanId: AirMapFlightPlanId?
	public var createdAt: Date = Date()
	public var startTime: Date? = Date()
	public var endTime: Date? {
		return startTime?.addingTimeInterval(duration)
	}
	public var duration: TimeInterval = 60*60 // 1 hour
	public var coordinate: Coordinate2D = Coordinate2D()
	public var maxAltitude: Meters?
	public var city: String!
	public var state: String!
	public var country: String!
	public var notify: Bool = true
	public var pilotId: AirMapPilotId!
	public var pilot: AirMapPilot? {
		didSet { pilotId = pilot?.id }
	}
	public var aircraft: AirMapAircraft? {
		didSet { aircraftId = aircraft?.id }
	}
	public var aircraftId: AirMapAircraftId!
	public var buffer: Meters?
	public var isPublic: Bool = false
	public var geometry: AirMapGeometry?
	
	public init() {}
	public required init?(map: Map) {}
}

extension AirMapFlight {
	
	public enum FlightType: String {
		case past
		case active
		case future
	}
	
	public func flightType() -> FlightType {
		guard let startTime = startTime, let endTime = endTime else { return .future }
		switch (startTime, endTime) {
		case let (start, end) where start.isInPast() && end.isInFuture():
			return .active
		case let (start, end) where start.isInFuture() && end.isInFuture():
			return .future
		default:
			return .past
		}
	}
}
