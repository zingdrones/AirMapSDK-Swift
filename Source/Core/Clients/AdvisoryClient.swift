//
//  AdvisoryClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 1/10/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation
import RxSwift
import SwiftTurf

internal class AdvisoryClient: HTTPClient {
	
	init() {
		super.init(basePath: Constants.AirMapApi.advisoryUrl)
	}
	
	enum AdvisoryClientError: Error {
		case invalidGeometry
	}
	
	// MARK: - Advisories

	func getAirspaceStatus(at point: Coordinate2D, buffer: Meters, rulesetIds: [String], from start: Date? = nil, to end: Date? = nil) -> Observable<AirMapAirspaceStatus> {
		
		let point = Point(geometry: point)
		guard let polygon = SwiftTurf.buffer(point, distance: buffer) else {
			return .error(AdvisoryClientError.invalidGeometry)
		}
		let geometry = AirMapPolygon(coordinates: polygon.geometry)

		return getAirspaceStatus(within: geometry, under: rulesetIds, from: start, to: end)
	}

	func getAirspaceStatus(along path: AirMapPath, buffer: Meters, rulesetIds: [String], from start: Date? = nil, to end: Date? = nil) -> Observable<AirMapAirspaceStatus> {
		
		let lineString = LineString(geometry: path.coordinates)
		guard let polygon = SwiftTurf.buffer(lineString, distance: buffer) else {
			return .error(AdvisoryClientError.invalidGeometry)
		}
		let geometry = AirMapPolygon(coordinates: polygon.geometry)
		
		return getAirspaceStatus(within: geometry, under: rulesetIds, from: start, to: end)
	}

	func getAirspaceStatus(within geometry: AirMapGeometry, under rulesetIds: [String], from start: Date? = nil, to end: Date? = nil) -> Observable<AirMapAirspaceStatus> {
		
		AirMap.logger.debug("Get Rules under", rulesetIds)
		var params = [String: Any]()
		params["geometry"] = geometry.params()
		params["rulesets"] = rulesetIds.csv
		params["start"] = start?.iso8601String()
		params["end"] = end?.iso8601String()
		
		return perform(method: .post, path: "/airspace", params: params)
	}
	
	// MARK: - Weather
	
	func getWeatherForecast(at coordinate: Coordinate2D, from: Date?, to: Date?) -> Observable<AirMapWeather> {
		
		AirMap.logger.debug("GET Weather", coordinate)
		var params = [String: Any]()
		params["latitude"] = coordinate.latitude
		params["longitude"] = coordinate.longitude
		params["start"] = from?.iso8601String()
		params["end"] = to?.iso8601String()
		
		return perform(method: .get, path: "/weather", params: params)
	}
}
