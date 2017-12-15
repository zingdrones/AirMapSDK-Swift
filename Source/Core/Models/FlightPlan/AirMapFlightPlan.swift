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
	
	public internal(set) var id: AirMapFlightPlanId?
	
	// Participants
	public var pilotId: AirMapPilotId?
	public var aircraftId: AirMapAircraftId?
	
	// Temporal constraints
	public var startTime: Date
	public var duration: TimeInterval
	
	// Computed end time; derived from start time + duration
	public var endTime: Date {
		return startTime.addingTimeInterval(duration)
	}

	// Spatial constraints
	public var geometry: AirMapGeometry?
	public var buffer: Meters? = 0
	public var takeoffCoordinate: Coordinate2D
	public var maximumAltitudeAGL: Meters?
	
	// Rulesets
	public var rulesetIds = [AirMapRulesetId]()

	// Flight Features
	public var flightFeaturesValue = [AirMapFlightFeatureId: Any]()

	// Assigned once a flight is created and associated with the flight plan
	public var flightId: AirMapFlightId?

	/// Designated flight plan initializer
	///
	/// - Parameters:
	///   - startTime: The date and time at which the flight will commence
	///   - duration: The duration of the flight plan
	///   - takeoffCoordinate: The take off coordinate of the flight plan
	public init(startTime: Date = Date(), duration: TimeInterval = 60*60, takeoffCoordinate: Coordinate2D) {
		self.startTime = startTime
		self.duration = duration
		self.takeoffCoordinate = takeoffCoordinate
	}

	// MARK: - JSON Serialization
	
	public required init?(map: Map) {
		
		do {
			let dateTransform = Constants.AirMapApi.dateTransform
			startTime = try map.value("start_time", using: dateTransform)
			let endTime: Date = try map.value("end_time", using: dateTransform)
			duration = endTime.timeIntervalSince(startTime)
			let takeoffLatitude = try map.value("takeoff_latitude") as Double
			let takeoffLongitude = try map.value("takeoff_longitude") as Double
			takeoffCoordinate = Coordinate2D(latitude: takeoffLatitude, longitude: takeoffLongitude)
		}
		catch {
			AirMap.logger.error(error)
			return nil
		}
	}
	
	public func mapping(map: Map) {
		
		let dateTransform = Constants.AirMapApi.dateTransform
		let geoJSONTransform = GeoJSONToAirMapGeometryTransform()

		id                  <-   map["id"]
		pilotId             <-   map["pilot_id"]
		aircraftId          <-   map["aircraft_id"]
		buffer              <-   map["buffer"]
		maximumAltitudeAGL  <-   map["max_altitude_agl"]
		startTime           <-  (map["start_time"], dateTransform)
		rulesetIds          <-   map["rulesets"]
		flightFeaturesValue <-   map["flight_features"]
		flightId            <-   map["flight_id"]

		switch map.mappingType {
		
		case .toJSON:
			takeoffCoordinate.latitude   >>>  map["takeoff_latitude"]
			takeoffCoordinate.longitude  >>>  map["takeoff_longitude"]
			polygonGeometry()  >>> (map["geometry"], geoJSONTransform)
			endTime  >>> (map["end_time"], dateTransform)

		case .fromJSON:
			do {
				let takeoffLatitude = try map.value("takeoff_latitude") as Double
				let takeoffLongitude = try map.value("takeoff_longitude") as Double
				takeoffCoordinate = Coordinate2D(latitude: takeoffLatitude, longitude: takeoffLongitude)
				geometry = try map.value("geometry", using: geoJSONTransform)
			}
			catch {
				print(error)
			}
		}
	}
	
}

extension AirMapFlightPlan {
	
	// FIXME: This is here because the API does not currently support anything other than polygons
	public func polygonGeometry() -> AirMapPolygon? {
		
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
