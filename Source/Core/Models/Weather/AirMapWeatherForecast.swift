//
//  AirMapWeatherForecast.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/20/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

/// A summary of past and future weather observations for a given location and time window
public struct AirMapWeather: Codable {
	
	/// A collection of hourly past or future weather observations/forecasts
	public let observations: [Observation]
	
	/// An object representative of historical or forecast observation
	public struct Observation: Codable {

		/// The start time of the observation
		public let time: Date
		
		/// A textual description of the conditions. e.g. "Sunny"
		public let condition: String
		
		/// An icon name constant that can be used to display a client-created image representative of the conditions
		public let icon: String
		
		/// The dew point in degrees celcius
		public let dewPoint: Celcius
		
		/// The atmospheric pressue in hPa
		public let pressure: HPa
		
		/// The percentage of relative humidity
		public let humidity: Double
		
		/// The minimum visibilty in kilometers
		public let visibility: Kilometers?
		
		/// Precipitation probability 0.0-1.0
		public let precipitation: Double
		
		/// The tempetrature in Celcius
		public let temperature: Celcius
		
		/// The bearing of the wind in degrees
		public let windBearing: Double?
		
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
