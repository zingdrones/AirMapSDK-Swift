//
//  AirMapConfiguration.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/10/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

/// Configuration class for the AirMap SDK. May be initialized programmatically or from an airmap.config.json file.
public struct AirMapConfiguration: Decodable {

	/// System used for displaying distance values
	public var distanceUnits: DistanceUnits = .metric

	/// Units used for displaying temperature values
	public var temperatureUnits: TemperatureUnits = .celcius

	/// Programmatic initializer when not providing an airmap.config.json file at the root of the project
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

		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase

		let json = try! JSONSerialization.data(withJSONObject: config, options: [])
		self = try! decoder.decode(AirMapConfiguration.self, from: json)
	}

	public let airmap: AirMapSettings
	public let mapbox: MapboxSettings
	public let auth0: Auth0Settings

	public struct AirMapSettings: Decodable {
		public let apiKey: String
		public let meta: [String: String]?
	}

	public struct MapboxSettings: Decodable {
		public let accessToken: String?
	}

	public struct Auth0Settings: Decodable {
		public let clientId: String
		public let host: String
	}

	private enum CodingKeys: String, CodingKey {
		case airmap, auth0, mapbox
	}

	public init(from decoder: Decoder) throws {

		let container = try decoder.container(keyedBy: CodingKeys.self)
		do {
			airmap = try container.decode(AirMapSettings.self, forKey: .airmap)
			mapbox = try container.decode(MapboxSettings.self, forKey: .mapbox)
			auth0 = try  container.decode(Auth0Settings.self,  forKey: .auth0)
		} catch let error as DecodingError {

			switch error {
			case .valueNotFound(let key, _):
				fatalError("""
					Configuration is missing the required \(key) key and value. If you have recently updated
					this SDK, you may need to visit the AirMap developer portal at https://dashboard.airmap.io/developer/
					for an updated airmap.config.json file.
					""")
			default:
				fatalError("Failed to initialize SDK. \(error.localizedDescription)")
			}
		}
	}

//	public let airMapDomain: String
//	public let airMapApiDomain: String
//	public let auth0Host: String
//	public let auth0ClientId: String
//
//	let airMapOverrides: [String: String]?
//	let airMapEnvironment: String?
//	let airMapPinCertificates: Bool
//	let airMapMapStyle: URL?
}

extension AirMapConfiguration {

	// A custom configuration manually set at runtime
	static var custom: AirMapConfiguration?

	// The default configuration loaded from a JSON configuration file
	static var json: AirMapConfiguration = {
		
		#if os(Linux)
		let configPath = "./airmap.config.json"
		#else
		let configPath = Bundle.main.path(forResource: "airmap.config", ofType: "json") ?? "missing"
		#endif
		
		do {
			let jsonString = try String(contentsOfFile: configPath)
			let decoder = JSONDecoder()
			decoder.keyDecodingStrategy = .convertFromSnakeCase
			return try decoder.decode(AirMapConfiguration.self, from: jsonString.data(using: .utf8)!)
		}
		catch {
			fatalError(
				"The `airmap.config.json` file required to configure the AirMapSDK is missing. " +
					"Please reference the documentation for more information. " +
				"https://developers.airmap.com/docs/ios-getting-started"
			)
		}
	}()
	
}

// JSON Serialization

extension AirMapConfiguration {
	//	fatalError(
	//	"Configuration is missing the required \(error.key!) key and value. If you have recently updated" +
	//	"this SDK, you may need to visit the AirMap developer portal at https://dashboard.airmap.io/developer/ " +
	//	"for an updated airmap.config.json file."
	//	)
	//	#if !os(Linux)
	//	if Locale.current.usesMetricSystem {
	//	temperatureUnits = .celcius
	//	distanceUnits = .metric
	//	} else {
	//	temperatureUnits = .fahrenheit
	//	distanceUnits = .imperial
	//	}
	//	#endif
}
