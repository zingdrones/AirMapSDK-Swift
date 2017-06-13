//
//  AirMapFlightPlan.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 5/21/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftTurf

public class AirMapFlightPlan: Mappable {
	
	public private(set) var id: String?
	
	// Participants
	public var pilotId: String?
	public var aircraftId: String?
	
	// Temporal constraints
	public var startTime: Date?
	public var endTime: Date? {
		return startTime?.addingTimeInterval(duration)
	}
	public var duration: TimeInterval = 60*60 // 1 hour default duration
	
	// Spatial constraints
	public var takeoffLatitude: Double
	public var takeoffLongitude: Double
	public var geometry: AirMapGeometry?
	public var buffer: Meters?
	public var minimumAltitudeAGL: Meters?
	public var maximumAltitudeAGL: Meters?
	public var targetAltitudeAGL: Meters?
	
	// Rulesets
	public var ruleSetsIds = [String]()
	
	// Flight Features
	public var flightFeaturesValue = [String: Any]()
	
	public init(coordinate: Coordinate2D) {
		self.takeoffLatitude = coordinate.latitude
		self.takeoffLongitude = coordinate.longitude
	}
	
	public required init?(map: Map) {
		
		do {
			takeoffLatitude   = try map.value("takeoff_latitude")
			takeoffLongitude  = try map.value("takeoff_longitude")
		}
		catch let error {
			print(error)
			return nil
		}
	}

	public func mapping(map: Map) {
		
		let dateTransform = CustomDateFormatTransform(formatString: Config.AirMapApi.dateFormat)
		let geoJSONTransform = GeoJSONToAirMapGeometryTransform()

		id                  <-  map["id"]
		pilotId             <-  map["pilot_id"]
		aircraftId          <-  map["aircraft_id"]
		takeoffLatitude     <-  map["takeoff_latitude"]
		takeoffLongitude    <-  map["takeoff_longitude"]
		targetAltitudeAGL   <-  map["target_altitude_agl"]
		buffer              <-  map["buffer"]
		geometry            <- (map["geometry"], geoJSONTransform)
		maximumAltitudeAGL  <-  map["max_altitude_agl"]
		minimumAltitudeAGL  <-  map["min_altitude_agl"]
		targetAltitudeAGL   <-  map["target_altitude_agl"]
		startTime           <- (map["start_time"], dateTransform)

		// derive duration from start and end time
		var endTime: Date?
		endTime <- (map["end_time"], dateTransform)
		if let startTime = startTime, let endTime = endTime {
			duration = endTime.timeIntervalSince(startTime)
		}
	}
	
}