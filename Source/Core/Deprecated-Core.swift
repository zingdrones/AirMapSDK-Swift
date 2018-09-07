//
//  Deprecated-Core.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/25/17.
/*
Copyright 2018 AirMap, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
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
