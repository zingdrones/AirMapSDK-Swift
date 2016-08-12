//
//  AirMapConfiguration.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/10/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapConfiguration: NSObject {
	
	public var environment: String?
	public var airMapApiKey: String!
	public var mapboxAccessToken: String?

	var auth0ClientId: String!
	var auth0CallbackUrl: String!
	
	static func loadConfig() -> AirMapConfiguration {
		
		let bundle = NSBundle.mainBundle()
		let configFile = bundle.pathForResource("airmap.config", ofType: "json")!
		let json = try? String(contentsOfFile: configFile)
		
		guard let config = Mapper<AirMapConfiguration>().map(json) else {
			fatalError(
				"The `airmap.config` file required to configure the AirMapSDK is missing. " +
				"Please reference the documentation for more information")
		}
		assert(config.airMapApiKey != nil, "`airmap.config` is missing the AirMap API Key")
		assert(config.auth0ClientId != nil, "`airmap.config` is missing the Auth0 Client ID")
		assert(config.auth0CallbackUrl != nil, "`airmap.config` is missing the Auth0 Callback URL")
		
		return config
	}
	
	public required init?(_ map: Map) {}
}

extension AirMapConfiguration: Mappable {

	public func mapping(map: Map) {
		environment       <-  map["airmap.environment"]
		airMapApiKey      <-  map["airmap.api_key"]
		auth0ClientId     <-  map["auth0.client_id"]
		auth0CallbackUrl  <-  map["auth0.callback_url"]
		mapboxAccessToken <-  map["mapbox.access_token"]
	}
}
