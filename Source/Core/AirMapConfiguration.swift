//
//  AirMapConfiguration.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/10/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapConfiguration {
		
	public var distanceUnits = DistanceUnits.metric
	public var temperatureUnits = TemperatureUnits.celcius
	
	internal fileprivate(set) var environment: String?
	public fileprivate(set) var airMapApiKey: String?
	public fileprivate(set) var mapboxAccessToken: String?

	internal fileprivate(set) var auth0ClientId: String!
	internal fileprivate(set) var auth0CallbackUrl: String!
	
	internal static func loadConfig() -> AirMapConfiguration {

		#if os(Linux)
			let configFile = "./config/airmap.config.json"
			guard
				let json = try? String(contentsOfFile: configFile) else {
					fatalError(
						"The `\(configFile)` file required to configure the AirMapSDK is missing. " +
						"Please reference the documentation for more information."
					)
			}
		#else
			let bundle = Bundle.main
			guard
				let configFile = bundle.path(forResource: "airmap.config", ofType: "json"),
				let json = try? String(contentsOfFile: configFile) else {
					fatalError(
						"The `airmap.config.json` file required to configure the AirMapSDK is missing. " +
							"Please reference the documentation for more information. " +
						"https://developers.airmap.com/docs/ios-getting-started"
					)
			}
		#endif

		guard
			let config = Mapper<AirMapConfiguration>().map(JSONString: json)
			else {
				fatalError(
					"Could not parse the AirMap configuration file" +
					"https://developers.airmap.com/docs/ios-getting-started"
				)
		}

		if config.airMapApiKey == nil {
			fatalError("airmap.config.json is missing an AirMap API Key (airmap.api_key)")
		}

		if config.auth0ClientId == nil {
			AirMap.logger.warning("airmap.config.json is missing an Auth0 Client ID (auth0.client_id)")
		}
		
		if config.auth0CallbackUrl == nil {
			AirMap.logger.warning("airmap.config.json is missing an Auth0 Callback URL (auth0.callback_url)")
		}
		
		if Locale.current.usesMetricSystem {
			config.temperatureUnits = .celcius
			config.distanceUnits = .metric
		} else {
			config.temperatureUnits = .fahrenheit
			config.distanceUnits = .imperial
		}
		
		return config
	}
	
	public required init?(map: Map) {}
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
