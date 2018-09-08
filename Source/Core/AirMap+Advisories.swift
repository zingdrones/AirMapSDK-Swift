//
//  AirMap+Advisories.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 4/8/17.
//  Copyright 2018 AirMap, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

extension AirMap {
	
	// MARK: - Advisories

	/// Get airspace status and advisories for a given point, buffer, and rulesets
	///
	/// - Parameters:
	///   - point: The coordinate to query
	///   - buffer: The buffer area surrounding the given point
	///   - rulesets: The rulesets under which to constrain the search
	///   - completion: The handler to call with the airspace advisory status result
	public static func getAirspaceStatus(at point: Coordinate2D, buffer: Meters, rulesetIds: [AirMapRulesetId], from start: Date? = nil, to end: Date? = nil, completion: @escaping (Result<AirMapAirspaceStatus>) -> Void) {
		rx.getAirspaceStatus(at: point, buffer: buffer, rulesetIds: rulesetIds, from: start, to: end).thenSubscribe(completion)
	}

	/// Get airspace status and advisories for a given path, buffer, and rulesets
	///
	/// - Parameters:
	///   - path: The path to query
	///   - buffer: The lateral buffer from the centerline of a given path
	///   - rulesets: The rulesets under which to constrain the search
	///   - completion: The handler to call with the airspace advisory status result
	public static func getAirspaceStatus(along path: AirMapPath, buffer: Meters, rulesetIds: [AirMapRulesetId], from start: Date? = nil, to end: Date? = nil, completion: @escaping (Result<AirMapAirspaceStatus>) -> Void) {
		rx.getAirspaceStatus(along: path, buffer: buffer, rulesetIds: rulesetIds, from: start, to: end).thenSubscribe(completion)
	}

	/// Get airspace status and advisories for a given geographic area and rulesets
	///
	/// - Parameters:
	///   - polygon: The geographic area to search
	///   - rulesets: The rulesets under which to constrain the search
	///   - completion: The handler to call with the airspace advisory status result
	public static func getAirspaceStatus(within polygon: AirMapPolygon, rulesetIds: [AirMapRulesetId], from start: Date? = nil, to end: Date? = nil, completion: @escaping (Result<AirMapAirspaceStatus>) -> Void) {
		rx.getAirspaceStatus(within: polygon, rulesetIds: rulesetIds, from: start, to: end).thenSubscribe(completion)
	}

	/// Get an hourly weather forecast for a given location and time window
	///
	/// - Parameters:
	///   - coordinate: The location of the forecast
	///   - from: The start time of the forecast
	///   - to: The end time of the forecst
	///   - completion: The handler to call with the forecast result
	public static func getWeatherForecast(at coordinate: Coordinate2D, from: Date? = nil, to: Date? = nil, completion: @escaping (Result<AirMapWeather>) -> Void) {
		rx.getWeatherForecast(at: coordinate, from: from, to: to).thenSubscribe(completion)
	}
	
}
