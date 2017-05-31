//
//  AirMapApiData.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/20/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapPath: AirMapGeometry, Mappable {

	public var coordinates: [Coordinate2D]!
	
	public var type: AirMapFlight.FlightGeometryType {
		return .path
	}
	
	init(coordinates: [Coordinate2D]) {
		self.coordinates = coordinates
	}

	required public init?(map: Map) {}

	public func params() -> [String: Any] {
		
		return [
			"type": "LineString",
			"coordinates": coordinates?.map({ [$0.longitude, $0.latitude] }) as Any
		]
	}
	
	public func mapping(map: Map) {
		
		coordinates	<-  map["coordinates"]
	}

}
