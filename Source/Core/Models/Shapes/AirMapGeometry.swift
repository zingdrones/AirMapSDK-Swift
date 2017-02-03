//
//  AirMapApiData.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/20/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

public protocol AirMapGeometry {
	
	var type: AirMapFlight.FlightGeometryType { get }
	func params() -> [String: Any]
}
