//
//  AirMap+Advisories.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 4/8/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation

extension AirMap {
	
	// MARK: - Advisories

	/// Get airspace status and advisories for a given geographic area and rulesets
	///
	/// - Parameters:
	///   - geometry: The geographic area to search
	///   - rulesets: The rulesets under which to constrain the search
	///   - completion: The handler to call with the airspace advisory status result
	public static func getAirspaceStatus(within geometry: AirMapGeometry, rulesetIds: [AirMapRulesetId], from start: Date? = nil, to end: Date? = nil, completion: @escaping (Result<AirMapAirspaceStatus>) -> Void) {
		rx.getAirspaceStatus(within: geometry, rulesetIds: rulesetIds, from: start, to: end).thenSubscribe(completion)
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
