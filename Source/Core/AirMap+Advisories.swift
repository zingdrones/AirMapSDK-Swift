//
//  AirMap+Advisories.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 4/8/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation

public typealias AirMap_Advisories = AirMap
extension AirMap_Advisories {
	
	/// Get airspace status and advisories for a given point, buffer, and rulesets
	///
	/// - Parameters:
	///   - point: The coordinate to query
	///   - buffer: The buffer area surrounding the given point
	///   - ruleSets: The rulesets under which to constrain the search
	///   - completion: The handler to call with the airspace advisory status result
	public static func getAirspaceStatus(at point: Coordinate2D, buffer: Meters, ruleSetIds: [String], from start: Date? = nil, to end: Date? = nil, completion: @escaping (Result<AirMapAirspaceAdvisoryStatus>) -> Void) {
		advisoryClient.getAirspaceStatus(at: point, buffer: buffer, ruleSetIds: ruleSetIds, from: start, to: end).thenSubscribe(completion)
	}

	/// Get airspace status and advisories for a given path, buffer, and rulesets
	///
	/// - Parameters:
	///   - path: The path to query
	///   - buffer: The buffer area surrounding the given point
	///   - ruleSets: The rulesets under which to constrain the search
	///   - completion: The handler to call with the airspace advisory status result
	public static func getAirspaceStatus(along path: AirMapPath, buffer: Meters, ruleSetIds: [String], from start: Date? = nil, to end: Date? = nil, completion: @escaping (Result<AirMapAirspaceAdvisoryStatus>) -> Void) {
		advisoryClient.getAirspaceStatus(along: path, buffer: buffer, ruleSetIds: ruleSetIds, from: start, to: end).thenSubscribe(completion)
	}

	/// Get airspace status and advisories for a given geographic area and rulesets
	///
	/// - Parameters:
	///   - polygon: The geographic area to search
	///   - ruleSets: The rulesets under which to constrain the search
	///   - completion: The handler to call with the airspace advisory status result
	public static func getAirspaceStatus(within polygon: AirMapPolygon, ruleSetIds: [String], from start: Date? = nil, to end: Date? = nil, completion: @escaping (Result<AirMapAirspaceAdvisoryStatus>) -> Void) {
		advisoryClient.getAirspaceStatus(within: polygon, under: ruleSetIds, from: start, to: end).thenSubscribe(completion)
	}

	/// Get an hourly weather forecast for a given location and time window
	///
	/// - Parameters:
	///   - coordinate: The location of the forecast
	///   - from: The start time of the forecast
	///   - to: The end time of the forecst
	///   - completion: The hanlder to call with the forecast result
	public static func getWeatherForecast(at coordinate: Coordinate2D, from: Date? = nil, to: Date? = nil, completion: @escaping (Result<AirMapWeather>) -> Void) {
		advisoryClient.getWeatherForecast(at: coordinate, from: from, to: to).thenSubscribe(completion)
	}
	
}
