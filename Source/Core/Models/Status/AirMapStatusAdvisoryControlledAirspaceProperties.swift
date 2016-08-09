//
//  AirMapStatusAdvisoryControlledAirspaceProperties.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/8/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

@objc public class AirMapStatusAdvisoryControlledAirspaceProperties: NSObject {

	public var classAirspace: String = ""
	public var airportIdentifier: NSDate?

	public required init?(_ map: Map) {}
}

extension AirMapStatusAdvisoryControlledAirspaceProperties: Mappable {

	public func mapping(map: Map) {
		classAirspace		<- map["class"]
		airportIdentifier	<- map["airport_identifier"]
	}
}
