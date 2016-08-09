//
//  AirMapStatusAdvisoryParksProperties.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/11/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

@objc public class AirMapStatusAdvisoryParkProperties: NSObject {

	public var size: Int? // size of park

	public required init?(_ map: Map) {}
}

extension AirMapStatusAdvisoryParkProperties: Mappable {

	public func mapping(map: Map) {
		size <- map["size"]
	}
}
