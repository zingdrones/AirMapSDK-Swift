//
//  AirMapStatusRequest.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import CoreLocation

internal struct AirMapStatusSharedRequestParams {
	
	var coordinate: CLLocationCoordinate2D?
	var types: [AirMapAirspaceType]?
	var ignoredTypes: [AirMapAirspaceType]?
	var weather: Bool?
	var date: NSDate?
	
	func params() -> [String: AnyObject] {
		
		var params = [String: AnyObject]()
		
		if let coordinate = coordinate where CLLocationCoordinate2DIsValid(coordinate) {
			params["latitude"] = coordinate.latitude
			params["longitude"] = coordinate.longitude
		}
		
		
		if types?.count > 0 {
			params["types"] = types?.flatMap({$0.type}).joinWithSeparator(",")
		}
		
		params["ignored_types"] = ignoredTypes?.flatMap({$0.type}).joinWithSeparator(",")
		params["weather"] = weather?.description
		params["datetime"] = date?.ISO8601String()
		
		return params
	}
}
