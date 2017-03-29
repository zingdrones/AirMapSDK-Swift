//
//  AirMap+Status.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/28/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

public typealias AirMap_Status = AirMap
extension AirMap_Status {
	
	public typealias AirMapStatusHandler = (AirMapStatus?, Error?) -> Void
	
	/// Check the airspace status of a given point & buffer (radius)
	///
	/// - Parameters:
	///   - coordinate: The latitude longitude of the point to check
	///   - buffer: The distance in meters to buffer around the center coordinate
	///   - types: Airspace types to include in the calculation & response.
	///   - ignoredTypes: Airspace types to ignore in the calculation & response
	///   - weather: Include current weather conditions in the response
	///   - date: Date and time for the status
	///   - completion: A completion handler to call with the Result
	public static func checkCoordinate(coordinate: Coordinate2D,
	                                   buffer: Meters,
	                                   types: [AirMapAirspaceType]? = nil,
	                                   ignoredTypes: [AirMapAirspaceType]? = nil,
	                                   weather: Bool = false,
	                                   date: Date = Date(),
	                                   completion: @escaping (Result<AirMapStatus>) -> Void) {
		
		statusClient
			.checkCoordinate(
				coordinate: coordinate,
				buffer: buffer,
				types: types,
				ignoredTypes: ignoredTypes,
				weather: weather,
				date: date)
			.subscribe(completion)
	}
	
	/// Check the airspace status of a given path & buffer
	///
	/// - Parameters:
	///   - path: Array of lat/lngs waypoints along a flight path
	///   - buffer: Buffer distance in meters from flight path center line
	///   - takeOffPoint: The take off point along the flight path
	///   - types: Airspace types to include in the calculation & response.
	///   - ignoredTypes: Airspace types to ignore in the calculation & response
	///   - weather: Include current weather conditions in the response
	///   - date: Date and time for the status
	///   - completion: A completion handler to call with the Result
	public static func checkFlightPath(path: [Coordinate2D],
	                                   buffer: Meters,
	                                   takeOffPoint: Coordinate2D,
	                                   types: [AirMapAirspaceType]? = nil,
	                                   ignoredTypes: [AirMapAirspaceType]? = nil,
	                                   weather: Bool = false,
	                                   date: Date = Date(),
	                                   completion: @escaping (Result<AirMapStatus>) -> Void) {
		
		statusClient
			.checkFlightPath(
				path: path,
				buffer: buffer,
				takeOffPoint: takeOffPoint,
				types: types,
				ignoredTypes: ignoredTypes,
				weather: weather,
				date: date)
			.subscribe(completion)
	}
	
	/// Check the airspace status of a given polygon (area) & buffer
	///
	/// - Parameters:
	///   - geometry: Array of lat/lngs for a flight area perimeter
	///   - takeOffPoint: The take off point within the flight area
	///   - types: Airspace types to include in the calculation & response.
	///   - ignoredTypes: Airspace types to ignore in the calculation & response
	///   - weather: Include current weather conditions in the response
	///   - date: Date and time for the status
	///   - completion: A completion handler to call with the Result
	public static func checkPolygon(geometry: [Coordinate2D],
	                                takeOffPoint: Coordinate2D,
	                                types: [AirMapAirspaceType]? = nil,
	                                ignoredTypes: [AirMapAirspaceType]? = nil,
	                                weather: Bool = false,
	                                date: Date = Date(),
	                                completion: @escaping (Result<AirMapStatus>) -> Void) {
		
		statusClient
			.checkPolygon(geometry: geometry,
			              takeOffPoint: takeOffPoint,
			              types: types,
			              ignoredTypes: ignoredTypes,
			              weather: weather,
			              date: date)
			.subscribe(completion)
	}
}
