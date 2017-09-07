//
//  AirMapApiData.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/20/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

public class AirMapPath: AirMapGeometry {

	public var coordinates: [Coordinate2D]!
	
	public var type: AirMapFlightGeometryType {
		return .path
	}
	
	public init(coordinates: [Coordinate2D]) {
		self.coordinates = coordinates
	}

	public func params() -> [String: Any] {
		
		return [
			"type": "LineString",
			"coordinates": coordinates?.map({ [$0.longitude, $0.latitude] }) as Any
		]
	}
}
