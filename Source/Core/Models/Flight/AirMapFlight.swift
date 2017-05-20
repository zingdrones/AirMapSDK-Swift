//
//  AirMapFlight.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 4/18/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

// FIXME: Remove NSObject dependency
open class AirMapFlight: NSObject {
//open class AirMapFlight: Hashable, Equatable {

	public enum FlightGeometryType: String {
		case point
		case path
		case polygon
	}

	public enum FlightType: String {
		case past
		case active
		case future
	}

    public var id: String?
	public var createdAt: Date = Date()
	public var startTime: Date?
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
	public var permitsIds = [String]()
	public var pilotId: String!
	public var pilot: AirMapPilot? {
		didSet { pilotId = pilot?.id }
	}
	public var aircraft: AirMapAircraft? {
		didSet { aircraftId = aircraft?.id }
	}
	public var aircraftId: String!
	public var statuses = [AirMapFlightStatus]()
	public var buffer: Meters?
	public var isPublic: Bool = false
	public var geometry: AirMapGeometry?
	
	public required init?(map: Map) {}

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
	
	override open var hashValue: Int {
		return id?.hashValue ?? super.hashValue
	}
	
	public override init() {}
    
    @available(*, unavailable, renamed: "id")
    public var flightId: String?
}

extension AirMapFlight: Mappable {

	public func mapping(map: Map) {

		var lat: Double?
		var lng: Double?

		lat <- map["latitude"]
		lng <- map["longitude"]

		if let lat = lat, let lng = lng {
			coordinate.latitude = lat
			coordinate.longitude = lng
		}

		let dateTransform = CustomDateFormatTransform(formatString: Config.AirMapApi.dateFormat)

		id          <-  map["id"]
		createdAt   <- (map["creation_date"], dateTransform)
		startTime   <- (map["start_time"], dateTransform)
		maxAltitude <-  map["max_altitude"]
		city        <-  map["city"]
		state       <-  map["state"]
		country     <-  map["country"]
		notify      <-  map["notify"]
//		pilot       <-  map["pilot"]
		pilotId     <-  map["pilot_id"]
		aircraft    <-  map["aircraft"]
		aircraftId  <-  map["aircraft_id"]
		isPublic    <-  map["public"]
		statuses    <-  map["statuses"]
		permitsIds  <-  map["permits"]
		buffer      <-  map["buffer"]
		geometry    <- (map["geometry"], GeoJSONToAirMapGeometryTransform())
		
		var endTime: Date?
		endTime     <- (map["end_time"], dateTransform)
		
		if let startTime = startTime, let endTime = endTime {
			duration = endTime.timeIntervalSince(startTime)
		}
	}

	func params() -> [String: Any] {

		var params = [String: Any]()

		params["latitude"    ] = coordinate.latitude
		params["longitude"   ] = coordinate.longitude
		params["max_altitude"] = maxAltitude
		params["aircraft_id" ] = aircraftId
		params["public"      ] = isPublic
		params["notify"      ] = notify
		params["geometry"    ] = geometry?.params()
		params["buffer"      ] = buffer ?? 0
		params["permits"     ] = permitsIds

		if let startTime = startTime, let endTime = endTime {
			params["start_time"] = startTime.ISO8601String()
			params["end_time"  ] = endTime.ISO8601String()
		} else {
			let now = Date()
			params["start_time"] = now.ISO8601String()
			params["end_time"  ] = now.addingTimeInterval(duration).ISO8601String()
		}
		
		return params
	}

	fileprivate func polygonStringFromCoordinates(_ coordinates: [Coordinate2D]) -> String {
		let polygonString = coordinates.flatMap {"\($0.latitude) \($0.longitude)"}.joined(separator: ", ")
		return "POLYGON(\(polygonString))"
	}

	fileprivate func lineStringFromCoordinates(_ coordinates: [Coordinate2D]) -> String {
		let lineString = coordinates.flatMap {"\($0.latitude) \($0.longitude)"}.joined(separator: ", ")
		return "LINESTRING(\(lineString))"
	}
}

extension AirMapFlight {
	
	static public func ==(lhs: AirMapFlight, rhs: AirMapFlight) -> Bool {
		return lhs.id == rhs.id
	}
}
