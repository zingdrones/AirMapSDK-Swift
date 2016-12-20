//
//  AirMapConfiguration.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/10/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapConfiguration: NSObject {
	
	public enum DistanceUnits {
		case Meters
		case Feet
	}
	
	public enum TemperatureUnits {
		case Celcius
		case Fahrenheit
	}
	
	public var distanceUnits = DistanceUnits.Meters
	public var temperatureUnits = TemperatureUnits.Celcius
	
	public var environment: String?
	public var airMapApiKey: String!
	public var mapboxAccessToken: String?

	var auth0ClientId: String!
	var auth0CallbackUrl: String!
	
	static func loadConfig() -> AirMapConfiguration {
		
		let bundle = NSBundle.mainBundle()
		
		guard let
			configFile = bundle.pathForResource("airmap.config", ofType: "json"),
			json = try? String(contentsOfFile: configFile),
			config = Mapper<AirMapConfiguration>().map(json)
 		else {
 			fatalError(
 				"The `airmap.config.json` file required to configure the AirMapSDK is missing. " +
				"Please reference the documentation for more information. " +
				"https://developers.airmap.com/docs/ios-getting-started#section-3-download-an-airmap-configuration-file"
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
		
		let usesMetric = NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem)!.boolValue!
		
		if usesMetric {
			config.temperatureUnits = .Celcius
			config.distanceUnits = .Meters
		} else {
			config.temperatureUnits = .Fahrenheit
			config.distanceUnits = .Feet
		}
		
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
