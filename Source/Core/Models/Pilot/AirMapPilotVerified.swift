//
//  AirMapPilotVerified.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/27/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public struct AirMapPilotVerified {

	public let verified: Bool
}

extension AirMapPilotVerified: ImmutableMappable {
	
	public init(map: Map) throws {
		verified = try map.value("verified")
	}
}
