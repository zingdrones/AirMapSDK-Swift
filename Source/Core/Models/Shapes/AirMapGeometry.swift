//
//  AirMapApiData.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/20/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation
import SwiftTurf

public enum AirMapGeometry: Codable {
	case point(geo: Coordinate2D, buffer: Meters)
	case path(geo: [Coordinate2D], buffer: Meters)
	case polygon(geo: [[Coordinate2D]])
}

extension AirMapGeometry {
	
	public func geoJSONRepresentation() -> GeoJSONDictionary {
		switch self {
		case .point(let geo, _):
			return Point(geometry: geo)
				.geoJSONRepresentation()
		case .path(let geo, _):
			return LineString(geometry: geo)
				.geoJSONRepresentation()
		case .polygon(let geo):
			return Polygon(geometry: geo)
				.geoJSONRepresentation()
		}
	}

	public func polygonGeometry() -> AirMapGeometry? {
		switch self {
		case .point(let geo, let buffer):
			let point = Point(geometry: geo)
			guard let buffered = SwiftTurf.buffer(point, distance: buffer) else {
				return nil
			}
			return .polygon(geo: buffered.geometry)
		case .path(let geo, let buffer):
			let lineString = LineString(geometry: geo)
			guard let buffered = SwiftTurf.buffer(lineString, distance: buffer) else {
				return nil
			}
			return .polygon(geo: buffered.geometry)
		case .polygon:
			return self
		}
	}
}

extension AirMapGeometry {
	public func encode(to encoder: Encoder) throws {
		fatalError()
	}
	public init(from decoder: Decoder) throws {
		fatalError()
	}
}

//public enum AirMapFlightGeometryType: String, Codable {
//	case point
//	case path
//	case polygon
//}
