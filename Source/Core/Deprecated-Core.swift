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
		return id?.rawValue
	}
}

extension AirMapPilot {
	
	@available(*, unavailable, renamed: "id")
	open var pilotId: String! {
		return id.rawValue
	}
}

extension AirMapAircraft {
	
	@available(*, unavailable, renamed: "id")
	public var aircraftId: String? {
		return id?.rawValue
	}
}

extension AirMapAdvisory {
	
	@available(*, unavailable, message: "Removed")
	public var distance: Meters {
		fatalError()
	}
}

@available (*, unavailable, renamed: "AirMapAirspaceStatus")
public class AirMapStatus {
	@available (*, unavailable, renamed: "AirMapAdvisory.Color")
	enum StatusColor {}
}

@available (*, unavailable, renamed: "AirMapAdvisory")
class AirMapStatusAdvisory {}

extension AirMap {
	
	@available (*, unavailable, message: "Use AirMap.getAirspaceStatus(at:buffer:rulesetIds:completion:)")
	public static func checkCoordinate(coordinate: Coordinate2D,
	                                   buffer: Meters,
	                                   types: [AirMapAirspaceType]? = nil,
	                                   ignoredTypes: [AirMapAirspaceType]? = nil,
	                                   weather: Bool = false,
	                                   date: Date = Date(),
									   completion: @escaping (Result<AirMapAirspaceStatus>) -> Void) { }
	
	@available (*, unavailable, message: "Use AirMap.getAirspaceStatus(along:buffer:rulesetIds:completion:)")
	public static func checkFlightPath(path: [Coordinate2D],
	                                   buffer: Meters,
	                                   takeOffPoint: Coordinate2D,
	                                   types: [AirMapAirspaceType]? = nil,
	                                   ignoredTypes: [AirMapAirspaceType]? = nil,
	                                   weather: Bool = false,
	                                   date: Date = Date(),
									   completion: @escaping (Result<AirMapAirspaceStatus>) -> Void) { }
	
	@available (*, unavailable, message: "Use AirMap.getAirspaceStatus(within:buffer:rulesetIds:completion:)")
	public static func checkPolygon(geometry: [Coordinate2D],
	                                takeOffPoint: Coordinate2D,
	                                types: [AirMapAirspaceType]? = nil,
	                                ignoredTypes: [AirMapAirspaceType]? = nil,
	                                weather: Bool = false,
	                                date: Date = Date(),
									completion: @escaping (Result<AirMapAirspaceStatus>) -> Void) {
	}
}
