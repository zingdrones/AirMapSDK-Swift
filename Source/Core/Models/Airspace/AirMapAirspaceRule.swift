//
//  AirMapAirspaceRule.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/29/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapAirspaceRule {

	public var name: String!
	public var geometry: AirMapGeometry!
	
	public required init?(map: Map) {}
}

extension AirMapAirspaceRule: Mappable {
	
	public func mapping(map: Map) {
		name        <-  map["name"]
		geometry    <- (map["geometry"], GeoJSONToAirMapGeometryTransform())
	}
	
}
