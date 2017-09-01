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
	public var buffer: Meters? = 0
	public var minimumAltitudeAGL: Meters?
	public var maximumAltitudeAGL: Meters?
	public var targetAltitudeAGL: Meters?
	
	// Assigned once a flight is created
	public var flightId: String?
	
	public var takeoffCoordinate: Coordinate2D {
		get {
			return Coordinate2D(latitude: takeoffLatitude, longitude: takeoffLongitude)
		}
		set {
			takeoffLatitude = newValue.latitude
			takeoffLongitude = newValue.longitude
		}
	}
	
	// Rulesets
	public var rulesetIds = [String]()
	
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
		rulesetIds          <-  map["rulesets"]
		flightFeaturesValue <-  map["flight_features"]
		flightId            <-  map["flight_id"]
		
		// derive duration from start and end time
		var endTime: Date?
		endTime <- (map["end_time"], dateTransform)
		if let startTime = startTime, let endTime = endTime {
			duration = endTime.timeIntervalSince(startTime)
		}
	}
	
	func params() -> [String: Any] {
		
		var params = [String: Any]()
		
		params["id"] = id
		params["pilot_id"] = pilotId
		params["aircraft_id"] = aircraftId
		params["takeoff_latitude"] = takeoffLatitude
		params["takeoff_longitude"] = takeoffLongitude
		params["aircraft_id"] = aircraftId
		// FIXME: See func polygonGeometry() below
		params["geometry"] = geometry?.params() // polygonGeometry()?.params()
		params["buffer"] = buffer
		params["max_altitude_agl"] = maximumAltitudeAGL ?? 0
		params["rulesets"] = rulesetIds
		params["flight_features"] = flightFeaturesValue
		
		if let startTime = startTime, let endTime = endTime {
			params["start_time"] = startTime.ISO8601String()
			params["end_time"] = endTime.ISO8601String()
		} else {
			let now = Date()
			params["start_time"] = now.ISO8601String()
			params["end_time"] = now.addingTimeInterval(duration).ISO8601String()
		}
		return params
	}
	
	// FIXME: This is here because the API does not currently support anything other than polygons
	func polygonGeometry() -> AirMapPolygon? {
		
		guard let geometry = geometry else { return nil }
		
		switch geometry {
			
		case let point as AirMapPoint:
			let point = Point(geometry: point.coordinate)
			if let bufferedPoint = SwiftTurf.buffer(point, distance: buffer ?? 0) {
				return AirMapPolygon(coordinates: bufferedPoint.geometry)
			} else {
				return nil
			}
			
		case let path as AirMapPath:
			let path = LineString(geometry: path.coordinates)
			if let bufferedPath = SwiftTurf.buffer(path, distance: buffer ?? 0) {
				return AirMapPolygon(coordinates: bufferedPath.geometry)
			} else {
				return nil
			}
			
		case let polygon as AirMapPolygon:
			return polygon
				
		default:
			break
		}
		
		return nil
	}
}
