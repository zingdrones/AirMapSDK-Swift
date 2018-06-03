//
//  AirMapFlight.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 4/18/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

public class AirMapFlight: Codable {
	
    public let id: AirMapFlightId
	public let flightPlanId: AirMapFlightPlanId?

	public let startTime: Date
	public internal(set) var endTime: Date

	public var duration: TimeInterval {
		return endTime.timeIntervalSince(startTime)
	}

	public let geometry: AirMapGeometry
	public let maxAltitude: Meters
	public let coordinate: Coordinate2D

	public let pilotId: AirMapPilotId?
	public let pilot: AirMapPilot?

	public let aircraftId: AirMapAircraftId?
	public let aircraft: AirMapAircraft?

	public let isPublic: Bool

	public let city: String?
	public let state: String?
	public let country: String?

	public let creationDate: Date?
}

extension AirMapFlight {
	
	public enum FlightType {
		case past
		case active
		case future
	}
	
	public var type: FlightType {

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
