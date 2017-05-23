//
//  AirMapPolygon.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/20/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapPolygon: AirMapGeometry, Mappable {

	public var coordinates: [[Coordinate2D]]!
		
	public var type: AirMapFlight.FlightGeometryType {
		return .polygon
	}
	
	public init(coordinates: [[Coordinate2D]]) {
		self.coordinates = coordinates
	}

	required public init?(map: Map) {}

	public func params() -> [String: Any] {
		
		var params = [String: Any]()
		
		if (coordinates?.count ?? 0) >= 1 {
			params["type"] = "Polygon"
			params["coordinates"] = coordinates
				.map { coordinates in
					var coordinates = coordinates
					// Connect the last point to the first
					coordinates.append(coordinates.first!)
					return coordinates.map { coordinate in
						[coordinate.longitude, coordinate.latitude]
					}
				} as [[[Double]]] as AnyObject?
		}
		
		return params
	}

	open func mapping(map: Map) {
		var coords: [[[Double]]] = []
		coords      <-  map["coordinates"]
		coordinates = coords
			.map { polygon in
				polygon
					.map { ($0[1], $0[0]) }
					.map(Coordinate2D.init)
			}
	}
	
}
