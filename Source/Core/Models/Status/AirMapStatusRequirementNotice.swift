//
//  AirMapStatusRequirementsNotice.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

@objc public class AirMapStatusRequirementNotice: NSObject {
	
	public var digital = false
	public var phoneNumber = ""
	
	public required init?(_ map: Map) {}
}

extension AirMapStatusRequirementNotice: Mappable {
	
	public func mapping(map: Map) {
		digital     <- map["digital"]
		phoneNumber <- map["phone"]
	}
}
