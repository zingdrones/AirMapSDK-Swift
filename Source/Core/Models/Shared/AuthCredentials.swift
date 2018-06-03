//
//  Auth0Credentials.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 3/3/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

public struct Auth0Credentials: Codable {
    
    let accessToken: String
    let refreshToken: String
	let tokenType: String
    let idToken: String
}
