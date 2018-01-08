//
//  AirMapTrafficService+Utils.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/2/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

open class AirMapTrafficServiceUtils {

	open static func directionFromBearing(_ bearing: Double) -> String {
		let index = Int((bearing/22.5) + 0.5) % 16
		let directions = self.compassDirections()
		return directions[index]
	}

	static func compassDirections() -> [String] {
		
		let localized = LocalizedStrings.CardinalDirection.self
		
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
	
}
