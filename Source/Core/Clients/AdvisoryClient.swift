//
//  AdvisoryClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 1/10/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation
import RxSwift

internal class AdvisoryClient: HTTPClient {
	
	init() {
		super.init(basePath: Config.AirMapApi.advisoryUrl)
	}
	
	enum AdvisoryClientError: Error {
		case invalidPolygon
	}
	
	func getAirspaceStatus(within geometry: AirMapGeometry, under ruleSetIds: [String], from start: Date? = nil, to end: Date? = nil) -> Observable<AirMapAirspaceAdvisoryStatus> {
		
		AirMap.logger.debug("GET Rules under", ruleSetIds)
		let geometryData = try! JSONSerialization.data(withJSONObject: geometry.geoJSONDictionary, options: [])
		let geometryJSON = String(data: geometryData, encoding: .utf8)
		var params = [String: Any]()
		params["geometry"] = geometryJSON ?? ""
		params["rulesets"] = ruleSetIds.joined(separator: ",")
		params["start"] = start?.ISO8601String()
		params["end"] = end?.ISO8601String()
		
		return perform(method: .get, path: "/airspace", params: params)
	}
	
	func getWeatherForecast(at coordinate: Coordinate2D, from: Date?, to: Date?) -> Observable<AirMapWeatherForecast> {
		
		AirMap.logger.debug("GET Weather", coordinate)
		var params = [String: Any]()
		params["latitude"] = coordinate.latitude
		params["longitude"] = coordinate.longitude
		params["start"] = from?.ISO8601String()
		params["end"] = to?.ISO8601String()
		
		return perform(method: .get, path: "/weather", params: params)
	}
}
