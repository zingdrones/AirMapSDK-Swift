//
//  AirMap+Status.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/28/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

private typealias AirMap_Status = AirMap
extension AirMap_Status {
	
	public typealias AirMapStatusHandler = (AirMapStatus?, NSError?) -> Void
	
	/**
	
	Check the `AirMapStatus` of a single point & radius-based flight
	
	- parameter coordinate: The lat/lng center of a flight
	- parameter buffer: Number of meters to buffer around a flight's center coordinate
	- parameter types: Array Map Layer types to include in the calculation & response
	- parameter ignoredTypes: Array Map Layer types to ignore in the calculation & response
	- parameter weather: If set to true, shows current weather conditions in the response
	- parameter date: Date and time for planned flight
	- parameter handler: `(AirMapStatus?, NSError?) -> Void`
	
	*/
	public class func checkCoordinate(coordinate: CLLocationCoordinate2D,
	                                  buffer: Double,
	                                  types: [AirMapAirspaceType]? = nil,
	                                  ignoredTypes: [AirMapAirspaceType]? = nil,
	                                  weather: Bool = false,
	                                  date: NSDate = NSDate(),
	                                  handler: AirMapStatusHandler) {
		
		statusClient.checkCoordinate(coordinate,
			buffer: buffer,
			types: types,
			ignoredTypes: ignoredTypes,
			weather: weather,
			date: date)
			.subscribe(handler)
	}
	
	/**
	
	Check the `AirMapStatus` of a multi-point path-based flight
	
	- parameter path: Array of lat/lngs along a flight path
	- parameter buffer: Path buffer in meters
	- parameter takeOffPoint: The take off point along the flight path
	- parameter types: Array Map Layer types to include in the calculation & response
	- parameter ignoredTypes: Array Map Layer types to ignore in the calculation & response
	- parameter weather: If set to true, shows current weather conditions in the response
	- parameter date: Date for planned flight
	- parameter handler: `(AirMapStatus?, NSError?) -> Void`
	
	*/
	public class func checkFlightPath(path: [CLLocationCoordinate2D],
	                                  buffer: Int,
	                                  takeOffPoint: CLLocationCoordinate2D,
	                                  types: [AirMapAirspaceType]? = nil,
	                                  ignoredTypes: [AirMapAirspaceType]? = nil,
	                                  weather: Bool = false,
	                                  date: NSDate = NSDate(),
	                                  handler: AirMapStatusHandler) {
		
		statusClient.checkFlightPath(
			path,
			buffer: buffer,
			takeOffPoint: takeOffPoint,
			types: types,
			ignoredTypes: ignoredTypes,
			weather: weather,
			date: date)
			.subscribe(handler)
	}
	
	/**
	
	Check the `AirMapStatus` of a polygon-based flight area
	
	- parameter geometry: Array of lat/lngs for a flight area
	- parameter takeOffPoint: The take off point along the flight path
	- parameter types: Array Map Layer types to include in the calculation & response
	- parameter ignoredTypes: Array Map Layer types to ignore in the calculation & response
	- parameter weather: If set to true, shows current weather conditions in the response
	- parameter date: Date for planned flight
	- parameter handler: `(AirMapStatus?, NSError?) -> Void`
	
	*/
	public class func checkPolygon(geometry: [CLLocationCoordinate2D],
	                               takeOffPoint: CLLocationCoordinate2D,
	                               types: [AirMapAirspaceType]? = nil,
	                               ignoredTypes: [AirMapAirspaceType]? = nil,
	                               weather: Bool = false,
	                               date: NSDate = NSDate(),
	                               handler: AirMapStatusHandler) {
		
		statusClient.checkPolygon(
			geometry,
			takeOffPoint: takeOffPoint,
			types: types,
			ignoredTypes: ignoredTypes,
			weather: weather,
			date: date)
			.subscribe(handler)
	}
	
}
