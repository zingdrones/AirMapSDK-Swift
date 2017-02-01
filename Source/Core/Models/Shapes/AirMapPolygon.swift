//
//  AirMapApiData.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/20/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapPolygon: AirMapGeometry, Mappable {

	public var coordinates: [[CLLocationCoordinate2D]]!
	
	/**
	Returns key value parameters
	
	- returns: [String: AnyObject]
	*/
	override public func params() -> [String: AnyObject] {
		
		var params = [String: AnyObject]()
		
		if coordinates?.count >= 1 {
			params["type"] = "Polygon"
			params["coordinates"] = coordinates
				.map { coordinates in
					var coordinates = coordinates
					// Connect the last point to the first
					coordinates.append(coordinates.first!)
					return coordinates.map { coordinate in
						[coordinate.longitude, coordinate.latitude]
					}
				} as [[[Double]]]
		}
		
		return params
	}

	public func mapping(map: Map) {
		var coords: [[[Double]]] = []
		coords      <-  map["coordinates"]
		coordinates = coords
			.map { polygon in
				polygon
					.map { ($0[1], $0[0]) }
					.map(CLLocationCoordinate2D.init)
			}
	}
	
	public override init() {
		super.init()
	}
	
	required public init?(_ map: Map) {
		super.init()
	}

}
