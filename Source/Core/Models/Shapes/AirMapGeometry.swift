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

import SwiftTurf

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
