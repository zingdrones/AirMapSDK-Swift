//
//  AirMapFlight.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 4/18/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public enum AirMapFlightGeometryType: String {
	case point
	case path
	case polygon
}

public class AirMapFlight {
	
    public var id: String?
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
	public var pilotId: String!
	public var pilot: AirMapPilot? {
		didSet { pilotId = pilot?.id }
	}
	public var aircraft: AirMapAircraft? {
		didSet { aircraftId = aircraft?.id }
	}
	public var aircraftId: String!
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
