//
//  AirMapWeatherForecast.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/20/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation

/// A summary of past and future weather observations for a given location and time window
public struct AirMapWeather {
	
	/// A collection of hourly past or future weather observations/forecasts
	public let observations: [Observation]
	
	/// An object representative of historical or forecast observation
	public struct Observation {

		/// The start time of the observation
		public let time: Date
		
		/// A textual description of the conditions. e.g. "Sunny"
		public let condition: String
		
		/// An icon name constant that can be used to display a client-created image representative of the conditions
		public let icon: String
		
		/// The dew point in degrees celcius
		public let dewPoint: Celcius
		
		/// The atmospheric pressue in hPa
		public let pressure: Double
		
		/// The percentage of relative humidity
		public let humidity: Double
		
		/// The minimum visibilty in kilometers
		public let visibility: Kilometers?
		
		/// Precipitation accumulation in centimeters
		public let precipitation: Double
		
		/// The tempetrature in Celcius
		public let temperature: Celcius
		
		/// The bearing of the wind in degrees
		public let windBearing: Double
		
		/// The speed of the wind in meters per second
		public let windSpeed: MetersPerSecond
		
		/// The peak gust speed of the wind in meters per second
		public let windGusting: MetersPerSecond?
	}
	
	/// The source of the weather observations
	public let attribution: String

	/// A url for the attribution source
	public let attributionUrl: URL
}

// MARK: - JSON Serialization

import ObjectMapper

extension AirMapWeather: ImmutableMappable {
	
	public init(map: Map) throws {
		do {
			attribution     = try map.value("attribution")
			attributionUrl  = try map.value("attribution_uri", using: URLTransform())
			observations    = try map.value("weather")
		}
		catch let error {
			print(error)
			throw error
		}
	}
}

extension AirMapWeather.Observation: ImmutableMappable {
	
	private static let dateTransform = CustomDateFormatTransform(formatString: Config.AirMapApi.dateFormat)

	public init(map: Map) throws {
		do {
			time          =  try  map.value("time", using: AirMapWeather.Observation.dateTransform)
			condition     =  try  map.value("condition")
			icon          =  try  map.value("icon")
			dewPoint      =  try  map.value("dew_point")
			pressure      =  try  map.value("mslp")
			humidity      =  try  map.value("humidity")
			visibility    =  try? map.value("visibility")
			precipitation =  try  map.value("precipitation")
			temperature   =  try  map.value("temperature")
			windBearing   =  try  map.value("wind.heading")
			windSpeed     =  try  map.value("wind.speed")
			windGusting   =  try? map.value("wind.gusting")
		}
		catch let error {
			print(error)
			throw error
		}
	}
}
