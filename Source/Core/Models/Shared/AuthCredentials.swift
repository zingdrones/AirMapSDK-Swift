//
//  Auth0Credentials.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 3/3/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public struct Auth0Credentials {
    
    let accessToken: String
    let refreshToken: String
	let tokenType: String
    let idToken: String
}

// MARK: - JSON Serialization

extension Auth0Credentials: ImmutableMappable {
	
	public init(map: Map) throws {
		accessToken   =  try map.value("access_token")
		refreshToken  =  try map.value("refresh_token")
		tokenType     =  try map.value("token_type")
		idToken       =  try map.value("id_token")
	}
}
