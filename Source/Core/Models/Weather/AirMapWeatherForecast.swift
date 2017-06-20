//
//  AirMapWeatherForecast.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/20/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public struct AirMapWeatherForecast: Mappable {
	
	public let attribution: String
	public let attributionUrl: URL
	public let weather: [Weather]
	
	public init?(map: Map) {
		do {
			attribution     = try map.value("attribution")
			attributionUrl  = try map.value("attribution_uri", using: URLTransform())
			weather         = try map.value("weather")
		}
		catch let error {
			print(error)
			return nil
		}
	}
	
	public func mapping(map: Map) {}
	
	public struct Weather: Mappable {
		
		public let time: Date
		public let condition: String
		public let icon: String
		public let dewPoint: Double
		public let pressure: Double
		public let humidity: Double
		public let visibility: Double
		public let precipitation: Double
		public let temperature: Celcius
		public let windHeading: Double
		public let windSpeed: MetersPerSecond
		public let windGusting: MetersPerSecond?
		
		private static let dateTransform = CustomDateFormatTransform(formatString: Config.AirMapApi.dateFormat)
		
		public init?(map: Map) {
			do {
				time          =  try  map.value("time", using: Weather.dateTransform)
				condition     =  try  map.value("condition")
				icon          =  try  map.value("icon")
				dewPoint      =  try  map.value("dew_point")
				pressure      =  try  map.value("mslp")
				humidity      =  try  map.value("humidity")
				visibility    =  try  map.value("visibility")
				precipitation =  try  map.value("precipitation")
				temperature   =  try  map.value("temperature")
				windHeading   =  try  map.value("wind.heading")
				windSpeed     =  try  map.value("wind.speed")
				windGusting   =  try? map.value("wind.gusting")
			}
			catch let error {
				print(error)
				return nil
			}
		}
		
		public func mapping(map: Map) {}
	}
}
