//
//  AirMapApiData.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/20/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public protocol AirMapGeometry: Mappable {
	
	var type: AirMapFlight.FlightGeometryType { get }
	func params() -> [String: Any]
}
