//
//  AirMapTrafficService+Utils.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/2/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//


public class AirMapTrafficServiceUtils {

	public class func directionFromBearing(bearing: Double) -> String {
		let index = Int((bearing/22.5) + 0.5) % 16
		let directions = self.compassDirections()
		return directions[index]
	}

	class func compassDirections() -> [String] {
		return ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
	}

	class func secondsFromDistanceAndSpeed(distance: Double, speedInKts: Int) -> Int {

		return Int(distance / (Double(speedInKts)*1852) * 3600)
	}

	class func metersToMiles(meters: Double, rounded: Bool = true) -> Double {

		if rounded {
			return (round((meters * 0.000621369647819236) * 10) / 10)
		}

		return meters * 0.000621369647819236
	}
}
