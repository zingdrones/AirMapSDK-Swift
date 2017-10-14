//
//  AirMapPolygon.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/20/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation
public class AirMapPolygon: AirMapGeometry {
	
	public var coordinates: [[Coordinate2D]]!
	
	public var type: AirMapFlightGeometryType {
		return .polygon
	}
	
	public init(coordinates: [[Coordinate2D]]) {
		self.coordinates = coordinates
	}
	
	public func params() -> [String: Any] {
		
		var params = [String: Any]()
		
		if (coordinates?.count ?? 0) >= 1 {
			
			let coordinates = self.coordinates.map { (coordinates) -> [Coordinate2D] in
				var newCoords = coordinates.reduce([Coordinate2D]()) { (result, next) -> [Coordinate2D] in
					var result = result
					if result.last != next {
						result.append(next)
					}
					return result
				}
				return newCoords
			}
			
			params["type"] = "Polygon"
			params["coordinates"] = coordinates
				.map { coordinates in
					return coordinates.map { coordinate in
						[coordinate.longitude, coordinate.latitude]
					}
				} as [[[Double]]] as AnyObject?
		}
		
		return params
	}
}

