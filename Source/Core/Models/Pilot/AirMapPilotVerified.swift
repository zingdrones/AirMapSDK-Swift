//
//  AirMapPilotVerified.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/27/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapPilotVerified {

	public var verified: Bool = false

	public required init?(map: Map) {}
}

extension AirMapPilotVerified: Mappable {

	public func mapping(map: Map) {
		verified	<- map["verified"]
	}
}
