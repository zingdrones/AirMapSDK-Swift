//
//  Auth0Credentials.swift
//  Pods
//
//  Created by Rocky Demoff on 3/3/17.
//
//

import ObjectMapper

open class Auth0Credentials {
    
    open var accessToken: String!
    open var refreshToken: String!
    open var idToken: String!
    open var tokenType:String!
    
    public required init?(map: Map) {}
}

extension Auth0Credentials: Mappable {
    
    public func mapping(map: Map) {
        accessToken  <- map["access_token"]
        refreshToken <- map["refresh_token"]
        tokenType    <- map["token_type"]
        idToken      <- map["id_token"]
    }
}
