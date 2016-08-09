//
//  AirMapApiData.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/20/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapPoint: AirMapGeometry {
	
	public var coordinate: CLLocationCoordinate2D!
}

extension AirMapPoint: Mappable {

	public func mapping(map: Map) {
		coordinate	<-  map["coordinates"]
	}

	/**
	Returns key value parameters

	- returns: [String: AnyObject]
	*/
	override public func params() -> [String: AnyObject] {

		var params = [String: AnyObject]()

		if let coords = coordinate {
			params["coordinates"] = [coords.latitude, coords.longitude]
		}

		return params
	}
	
}
