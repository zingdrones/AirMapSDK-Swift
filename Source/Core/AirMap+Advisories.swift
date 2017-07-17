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
	
	/// Get airspace status and advisories for a given geometry and rulesets
	///
	/// - Parameters:
	///   - geometry: The geographic area to search
	///   - ruleSets: The rulesets under which to constrain the search
	///   - completion: The handler to call with the airspace advisory status result
	public static func getAirspaceStatus(geometry: AirMapGeometry, ruleSetIds: [String], completion: @escaping (Result<AirMapAirspaceAdvisoryStatus>) -> Void) {
		advisoryClient.getAirspaceStatus(within: geometry, under: ruleSetIds).subscribe(completion)
	}
	
	/// Get an hourly weather forecast for a given location and time window
	///
	/// - Parameters:
	///   - coordinate: The location of the forecast
	///   - from: The start time of the forecast
	///   - to: The end time of the forecst
	///   - completion: The hanlder to call with the forecast result
	public static func getWeatherForecast(at coordinate: Coordinate2D, from: Date? = nil, to: Date? = nil, completion: @escaping (Result<AirMapWeatherForecast>) -> Void) {
		advisoryClient.getWeatherForecast(at: coordinate, from: from, to: to).subscribe(completion)
	}
	
}
