//
//  AirMapTrafficService+Utils.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/2/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

open class AirMapTrafficServiceUtils {
	
	open static func directionFromBearing(_ bearing: Double, localized: Bool = true) -> String {
		let index = Int((bearing/22.5) + 0.5) % 16
		let directions = self.compassDirections(localized: localized)
		return directions[index]
	}
	
	static func compassDirections(localized: Bool = true) -> [String] {
		
		let localizedStrings = LocalizedStrings.CardinalDirection.self
		
		if localized {
			return [
				localizedStrings.N,
				localizedStrings.NNE,
				localizedStrings.NE,
				localizedStrings.ENE,
				localizedStrings.E,
				localizedStrings.ESE,
				localizedStrings.SE,
				localizedStrings.SSE,
				localizedStrings.S,
				localizedStrings.SSW,
				localizedStrings.SW,
				localizedStrings.WSW,
				localizedStrings.W,
				localizedStrings.WNW,
				localizedStrings.NW,
				localizedStrings.NNW
			]
		} else {
			return [
				"N",
				"NNE",
				"NE",
				"ENE",
				"E",
				"ESE",
				"SE",
				"SSE",
				"S",
				"SSW",
				"SW",
				"WSW",
				"W",
				"WNW",
				"NW",
				"NNW"
			]
		}
	}
	
	static func secondsFromDistanceAndSpeed(_ distance: Meters, speedInKts: Double) -> TimeInterval {
		
		return distance / (speedInKts*1852) * 3600
	}
	
}
