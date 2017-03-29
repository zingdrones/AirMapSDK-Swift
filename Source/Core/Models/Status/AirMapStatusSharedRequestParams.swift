//
//  AirMapStatusRequest.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

internal struct AirMapStatusSharedRequestParams {
	
	var coordinate: Coordinate2D?
	var types: [AirMapAirspaceType]?
	var ignoredTypes: [AirMapAirspaceType]?
	var weather: Bool?
	var date: Date?
	
	func params() -> [String: Any] {
		
		var params = [String: Any]()
		
		if let coordinate = coordinate, coordinate.isValid {
			params["latitude"] = coordinate.latitude
			params["longitude"] = coordinate.longitude
		}
		
		params["types"] = types?.map{$0.rawValue}.joined(separator: ",")
		params["ignored_types"] = ignoredTypes?.flatMap{$0.rawValue}.joined(separator: ",")
		params["weather"] = weather?.description
		params["datetime"] = date?.ISO8601String()
		
		return params
	}
}
