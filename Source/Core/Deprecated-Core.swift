//
//  Deprecated-Core.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/25/17.
//

import Foundation

extension AirMapFlight {

	@available(*, unavailable, renamed: "id")
	public var flightId: String? {
		return id
	}
}

extension AirMapAircraft {
	
	@available(*, unavailable, renamed: "id")
	public var aircraftId: String? {
		return id
	}
}

public class AirMapStatus {}
public enum AirMapLayerType {}

extension AirMap {
	
	@available (*, unavailable, message: "Configure map using AirMapMapView.configure(rulesets:)")
	
	@available (*, unavailable, message: "Use AirMap.getAirspaceStatus")
	public static func checkCoordinate(coordinate: Coordinate2D,
	                                   buffer: Meters,
	                                   types: [AirMapAirspaceType]? = nil,
	                                   ignoredTypes: [AirMapAirspaceType]? = nil,
	                                   weather: Bool = false,
	                                   date: Date = Date(),
	                                   completion: @escaping (Result<AirMapStatus>) -> Void) { }
	
	@available (*, unavailable, message: "Use AirMap.getAirspaceStatus")
	public static func checkFlightPath(path: [Coordinate2D],
	                                   buffer: Meters,
	                                   takeOffPoint: Coordinate2D,
	                                   types: [AirMapAirspaceType]? = nil,
	                                   ignoredTypes: [AirMapAirspaceType]? = nil,
	                                   weather: Bool = false,
	                                   date: Date = Date(),
	                                   completion: @escaping (Result<AirMapStatus>) -> Void) { }
	
	@available (*, unavailable, message: "Use AirMap.getAirspaceStatus")
	public static func checkPolygon(geometry: [Coordinate2D],
	                                takeOffPoint: Coordinate2D,
	                                types: [AirMapAirspaceType]? = nil,
	                                ignoredTypes: [AirMapAirspaceType]? = nil,
	                                weather: Bool = false,
	                                date: Date = Date(),
	                                completion: @escaping (Result<AirMapStatus>) -> Void) {
	}
}
