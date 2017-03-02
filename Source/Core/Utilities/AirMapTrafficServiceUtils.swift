//
//  AirMapTrafficService+Utils.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/2/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//


open class AirMapTrafficServiceUtils {

	open static func directionFromBearing(_ bearing: Double) -> String {
		let index = Int((bearing/22.5) + 0.5) % 16
		let directions = self.compassDirections()
		return directions[index]
	}

	static func compassDirections() -> [String] {
		
		let bundle = AirMapBundle.core
		let localized = LocalizedString.CardinalDirection.self
		
		return [
			localized.N,
			localized.NNE,
			localized.NE,
			localized.ENE,
			localized.E,
			localized.ESE,
			localized.SE,
			localized.SSE,
			localized.S,
			localized.SSW,
			localized.SW,
			localized.WSW,
			localized.W,
			localized.WNW,
			localized.NW,
			localized.NNW
		]
	}

	static func secondsFromDistanceAndSpeed(_ distance: Meters, speedInKts: Double) -> TimeInterval {

		return distance / (speedInKts*1852) * 3600
	}
	
	static func knotsToMetersPerSecond(knots: Double) -> Meters {

		return knots * 0.514444
	}

	static func metersToMiles(_ meters: Meters, rounded: Bool = true) -> Miles {

		if rounded {
			return (round((meters * 0.000621369647819236) * 10) / 10)
		}

		return meters * 0.000621369647819236
	}
	
	static func metersToFeet(_ meters: Meters, rounded: Bool = true) -> Feet {
		
		if rounded {
			return (round((meters * 0.3048) * 10) / 10)
		}
		
		return meters * 0.3048
	}
}
