//
//  StatusClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/26/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift

internal class StatusClient: HTTPClient {

	init() {
		super.init(basePath: Config.AirMapApi.statusUrl)
	}

	/**

	Check the `AirMapStatus` of a single point & buffer-based flight

	- parameter coordinate: The lat/lng center of a flight
	- parameter buffer: Number of meters to buffer around a flight's center coordinate
	- parameter types: Array Map Layer types to include in the calculation & response
	- parameter ignoredTypes: Array Map Layer types to ignore in the calculation & response
	- parameter weather: If set to true, shows current weather conditions in the response
	- parameter date: Date and time for planned flight
	- returns: AirMapStatus promise

	*/
	func checkCoordinate(coordinate: Coordinate2D,
	                     buffer: Meters,
	                     types: [AirMapAirspaceType]? = nil,
	                     ignoredTypes: [AirMapAirspaceType]? = nil,
	                     weather: Bool = false,
	                     date: Date = Date()) -> Observable<AirMapStatus> {


		let sharedParams = AirMapStatusSharedRequestParams(coordinate: coordinate,
		                                                   types: types,
		                                                   ignoredTypes: ignoredTypes,
		                                                   weather: weather,
		                                                   date: date)
		var params = sharedParams.params()
		params["buffer"] = buffer

		return perform(method: .get, path: "/point", params: params)
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
	- retuns: AirMapStatus promise

	*/
	func checkFlightPath(path: [Coordinate2D],
	                     buffer: Meters,
	                     takeOffPoint: Coordinate2D,
	                     types: [AirMapAirspaceType]? = nil,
	                     ignoredTypes: [AirMapAirspaceType]? = nil,
	                     weather: Bool = false,
	                     date: Date = Date()) -> Observable<AirMapStatus> {
		
		let geo = geometricStringRepresentation(for: path)

		let sharedParams = AirMapStatusSharedRequestParams(coordinate: takeOffPoint,
		                                                   types: types,
		                                                   ignoredTypes: ignoredTypes,
		                                                   weather: weather,
		                                                   date: date)

		var params = sharedParams.params()
		params["geometry"] = "LINESTRING(\(geo))"
		params["buffer"] = buffer

		return perform(method: .get, path: "/path", params: params)
	}

	/**

	Check the `AirMapStatus` of a polygon-based flight area

	- parameter geometry: Array of lat/lngs for a flight area
	- parameter takeOffPoint: The take off point along the flight path
	- parameter types: Array Map Layer types to include in the calculation & response
	- parameter ignoredTypes: Array Map Layer types to ignore in the calculation & response
	- parameter weather: If set to true, shows current weather conditions in the response
	- parameter date: Date for planned flight
	- returns: AirMapStatus promise

	*/
	func checkPolygon(geometry: [Coordinate2D],
	                  takeOffPoint: Coordinate2D,
	                  types: [AirMapAirspaceType]? = nil,
	                  ignoredTypes: [AirMapAirspaceType]? = nil,
	                  weather: Bool = false,
	                  date: Date = Date()) -> Observable<AirMapStatus> {

		let geo = geometricStringRepresentation(for: geometry + [geometry.first!])

		let sharedParams = AirMapStatusSharedRequestParams(coordinate: takeOffPoint,
		                                                   types: types,
		                                                   ignoredTypes: ignoredTypes,
		                                                   weather: weather,
		                                                   date: date)

		var params = sharedParams.params()
		params["geometry"] = "POLYGON(\(geo))"

		return perform(method: .get, path: "/polygon", params: params)
	}

	// MARK: - Private

	/**
	Transforms a collection of `Coordinate2D` into a `String` representation
	- parameter geometry: A collection of `Coordinate2D` points
	- returns: A `String` representation of the geometry provided
	*/
	fileprivate func geometricStringRepresentation(for geometry: [Coordinate2D]) -> String {
		return geometry.map { "\($0.longitude) \($0.latitude)" }.joined(separator: ",")
	}

}
