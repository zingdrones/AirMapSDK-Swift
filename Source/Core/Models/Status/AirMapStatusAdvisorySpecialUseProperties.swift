//
//  AirMapStatusAdvisorySpecialUseAirspaceProperties.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/8/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

@objc public class AirMapStatusAdvisorySpecialUseProperties: NSObject {

	public var currentlyActive: Bool?
	public var desc: String?

	public required init?(_ map: Map) {}
}

extension AirMapStatusAdvisorySpecialUseProperties: Mappable {

	public func mapping(map: Map) {
		currentlyActive		<- map["endTime"]
		desc				<- map["decription"]
	}
}
