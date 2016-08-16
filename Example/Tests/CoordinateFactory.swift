//
//  CoordinateFactory.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/1/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import AirMap
import CoreLocation

class CoordinateFactory {

	static func whiteHouseCoordinate() -> CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: 38.8977, longitude: -77.0365)
	}

	static func klaxCoordinate() -> CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: 33.9416, longitude: -118.4085)
	}

	static func ksmoCoordinate() -> CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: 34.0160, longitude: -118.4510)
	}

	static func santaMonicaPierCoordinate() -> CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: 34.0099, longitude: -118.4964)
	}

	static func marinaDelReyMarinaPolygonCoordinates() -> [CLLocationCoordinate2D] {
		return [
			CLLocationCoordinate2D(latitude: 33.98572, longitude: -118.45184),
			CLLocationCoordinate2D(latitude: 33.98401, longitude: -118.45868),
			CLLocationCoordinate2D(latitude: 33.97561, longitude: -118.46000),
			CLLocationCoordinate2D(latitude: 33.96942, longitude: -118.45510),
			CLLocationCoordinate2D(latitude: 33.97006, longitude: -118.44463),
			CLLocationCoordinate2D(latitude: 33.97294, longitude: -118.44438),
			CLLocationCoordinate2D(latitude: 33.97665, longitude: -118.43816),
			CLLocationCoordinate2D(latitude: 33.98347, longitude: -118.44178),
			CLLocationCoordinate2D(latitude: 33.98572, longitude: -118.45184)
		]
	}

}
