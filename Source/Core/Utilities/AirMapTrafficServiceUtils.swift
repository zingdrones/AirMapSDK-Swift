//
//  AirMapTrafficService+Utils.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/2/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//


open class AirMapTrafficServiceUtils {

	open class func directionFromBearing(_ bearing: Double) -> String {
		let index = Int((bearing/22.5) + 0.5) % 16
		let directions = self.compassDirections()
		return directions[index]
	}

	class func compassDirections() -> [String] {
		return ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
	}

	class func secondsFromDistanceAndSpeed(_ distance: Meters, speedInKts: Double) -> TimeInterval {

		return distance / (speedInKts*1852) * 3600
	}

	class func metersToMiles(_ meters: Meters, rounded: Bool = true) -> Miles {

		if rounded {
			return (round((meters * 0.000621369647819236) * 10) / 10)
		}

		return meters * 0.000621369647819236
	}
	
	class func metersToFeet(_ meters: Meters, rounded: Bool = true) -> Feet {
		
		if rounded {
			return (round((meters * 0.3048) * 10) / 10)
		}
		
		return meters * 0.3048
	}
}
