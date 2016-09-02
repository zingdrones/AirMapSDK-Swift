//
//  AirMapToken.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 8/9/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

@objc public class AirMapToken: NSObject {

	public var authToken: String!
	public required init?(_ map: Map) {}
}

extension AirMapToken: Mappable {

	public func mapping(map: Map) {
		authToken	<-  map["id_token"]
	}
}
