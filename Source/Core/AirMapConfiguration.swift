//
//  AirMapConfiguration.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/10/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

/// Configuration class for the AirMap SDK. May be initialized programmatically or by using an airmap.config.json file.
public struct AirMapConfiguration {
		
	/// The AirMap API key that was used to initialize the SDK. Required.
	public let airMapApiKey: String
	
	/// An optional Mapbox access token to use with any map UI elements.
	public let mapboxAccessToken: String?
	
	/// Designated initializer when not providing an airmap.config.json file at the root of the project
	///
	/// - SeeAlso: https://developers.airmap.com/docs/ios-getting-started
	/// - Parameters:
	///   - apiKey: The AirMap API key to use with the AirMap API
	///   - auth0ClientId: A client ID used for user/pilot authentication with AirMap
	///   - mapboxAccessToken: An optional access token used to configure any map UI elements
	public init(apiKey: String, auth0ClientId: String, mapboxAccessToken: String? = nil) {
		
		let config = [
			"airmap": ["api_key": apiKey],
			"auth0":  ["client_id": auth0ClientId],
			"mapbox": ["access_token": mapboxAccessToken as Any]
		]
		
		try! self.init(JSON: config)
	}
	
	/// System used for displaying distance values
	public var distanceUnits: DistanceUnits = .metric
	
	/// Units used for displaying temperature values
	public var temperatureUnits: TemperatureUnits = .celcius

	public let airMapDomain: String
	public let auth0Host: String
	public let auth0ClientId: String
	
	let airMapApiOverrides: [String: String]?
	let airMapEnvironment: String?
	let airMapPinCertificates: Bool
	let airMapMapStyle: URL
}

extension AirMapConfiguration {
	
	static func defaultConfig() -> AirMapConfiguration {
		
		#if os(Linux)
			let configPath = "./airmap.config.json"
		#else
			let configPath = Bundle.main.path(forResource: "airmap.config", ofType: "json") ?? "missing"
		#endif
		
		do {
			let jsonString = try String(contentsOfFile: configPath)
			return try AirMapConfiguration(JSONString: jsonString)
		}
		catch {
			fatalError(
				"The `airmap.config.json` file required to configure the AirMapSDK is missing. " +
					"Please reference the documentation for more information. " +
				"https://developers.airmap.com/docs/ios-getting-started"
			)
		}
	}
}

// MARK: - JSON Serialization

import ObjectMapper

extension AirMapConfiguration: ImmutableMappable {
	
	public init(map: Map) throws {
	
		do {
			airMapApiKey          =  try  map.value("airmap.api_key")
			mapboxAccessToken     =  try? map.value("mapbox.access_token")
			auth0Host             = (try? map.value("auth0.host")) ?? "sso.airmap.io"
			auth0ClientId         =  try  map.value("auth0.client_id")
			airMapDomain          = (try? map.value("airmap.domain")) ?? "airmap.com"
			airMapEnvironment     =  try? map.value("airmap.environment")
			airMapApiOverrides    =  try? map.value("airmap.api_overrides")
			airMapPinCertificates = (try? map.value("airmap.pin_certificates")) ?? false
			airMapMapStyle        =  try  map.value("airmap.map_style")
		}
			
		catch let error as MapError {
			fatalError(
				"Configuration is missing the required \(error.key!) key and value. If you have recently updated" +
				"this SDK, you may need to visit the AirMap developer portal at https://dashboard.airmap.io/developer/ " +
				"for an updated airmap.config.json file."
			)
		}
		
		#if !os(Linux)
			if Locale.current.usesMetricSystem {
				temperatureUnits = .celcius
				distanceUnits = .metric
			} else {
				temperatureUnits = .fahrenheit
				distanceUnits = .imperial
			}
		#endif
	}
}
