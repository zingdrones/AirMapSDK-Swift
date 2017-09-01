//
//  AirMapToken.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 8/9/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public struct AirMapToken {

	public var authToken: String
}

// MARK: - JSON Serialization

extension AirMapToken: ImmutableMappable {
	
	public init(map: Map) throws {
		authToken = try map.value("id_token")
	}
}
