//
//  AirMapPilotVerified.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/27/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

@objc public class AirMapPilotVerified: NSObject {

	public var verified: Bool = false

	public required init?(_ map: Map) {}
}

extension AirMapPilotVerified: Mappable {

	public func mapping(map: Map) {
		verified	<- map["verified"]
	}
}
