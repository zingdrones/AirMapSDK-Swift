//
//  AirMapApiData.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/20/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper
import SwiftTurf

public class AirMapPoint: AirMapGeometry, Mappable {

	public var coordinate: Coordinate2D!

	public var type: AirMapFlight.FlightGeometryType {
		return .point
	}
	
	public init(coordinate: Coordinate2D) {
		self.coordinate = coordinate
	}
	
	required public init?(map: Map) {}

	public func mapping(map: Map) {
		coordinate	<-  map["coordinates"]
	}

	public func params() -> [String: Any] {
		
		return [
			"type": "Point",
			"coordinates": [coordinate.latitude, coordinate.longitude]
		]
	}
}
