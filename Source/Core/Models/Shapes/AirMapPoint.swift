//
//  AirMapApiData.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/20/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

public class AirMapPoint: AirMapGeometry {

	public var coordinate: Coordinate2D!

	public var type: AirMapFlightGeometryType {
		return .point
	}
	
	public init(coordinate: Coordinate2D) {
		self.coordinate = coordinate
	}
	
	public func params() -> [String: Any] {
		
		return [
			"type": "Point",
			"coordinates": [coordinate.longitude, coordinate.latitude]
		]
	}
}

