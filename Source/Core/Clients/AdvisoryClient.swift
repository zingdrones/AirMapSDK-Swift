//
//  AdvisoryClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 1/10/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import RxSwift
import SwiftTurf

internal class AdvisoryClient: HTTPClient {
	
	init() {
		super.init(basePath: Config.AirMapApi.advisoryUrl)
	}
	
	enum AdvisoryClientError: Error {
		case invalidPolygon
	}
	
	func getAirspaceStatus(within geometry: AirMapGeometry, under ruleSets: [AirMapRuleSet]) -> Observable<AirMapAirspaceAdvisoryStatus> {
		let ruleSetIdentifiers = ruleSets.identifiers
		AirMap.logger.debug("GET Rules under", ruleSetIdentifiers)
		let params: [String: Any] = [
			"geometry": geometry.geoJSONDictionary,
			"rulesets": ruleSetIdentifiers
		]
		
		return perform(method: .get, path: "/airspace", params: params)
	}
}

extension AirMapGeometry {
	
	var geoJSONDictionary: GeoJSONDictionary {
		switch self {
		case let point as AirMapPoint:
			return Point(geometry: point.coordinate).geoJSONRepresentation()
		case let polygon as AirMapPolygon:
			return Polygon(geometry: polygon.coordinates).geoJSONRepresentation()
		case let path as AirMapPath:
			return LineString(geometry: path.coordinates).geoJSONRepresentation()
		default:
			fatalError()
		}
	}
}
