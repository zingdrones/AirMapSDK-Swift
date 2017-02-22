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
		
		let bundle = AirMapBundle.main
		
		return [
			NSLocalizedString("CARDINAL_DIRECTION_N",    bundle: bundle, value: "N",   comment: "Abbreviation for North"),
			NSLocalizedString("CARDINAL_DIRECTION_NNNE", bundle: bundle, value: "NNE", comment: "Abbreviation for North North East"),
			NSLocalizedString("CARDINAL_DIRECTION_NE",   bundle: bundle, value: "NE",  comment: "Abbreviation for North East"),
			NSLocalizedString("CARDINAL_DIRECTION_ENE",  bundle: bundle, value: "ENE", comment: "Abbreviation for East North East"),
			NSLocalizedString("CARDINAL_DIRECTION_E",    bundle: bundle, value: "E",   comment: "Abbreviation for East"),
			NSLocalizedString("CARDINAL_DIRECTION_ESE",  bundle: bundle, value: "ESE", comment: "Abbreviation for East South East"),
			NSLocalizedString("CARDINAL_DIRECTION_SE",   bundle: bundle, value: "SE",  comment: "Abbreviation for South East"),
			NSLocalizedString("CARDINAL_DIRECTION_SSE",  bundle: bundle, value: "SSE", comment: "Abbreviation for South South East"),
			NSLocalizedString("CARDINAL_DIRECTION_S",    bundle: bundle, value: "S",   comment: "Abbreviation for South"),
			NSLocalizedString("CARDINAL_DIRECTION_SSW",  bundle: bundle, value: "SSW", comment: "Abbreviation for South South West"),
			NSLocalizedString("CARDINAL_DIRECTION_SW",   bundle: bundle, value: "SW",  comment: "Abbreviation for South West"),
			NSLocalizedString("CARDINAL_DIRECTION_WSW",  bundle: bundle, value: "WSW", comment: "Abbreviation for West South West"),
			NSLocalizedString("CARDINAL_DIRECTION_W",    bundle: bundle, value: "W",   comment: "Abbreviation for West"),
			NSLocalizedString("CARDINAL_DIRECTION_WNW",  bundle: bundle, value: "WNW", comment: "Abbreviation for West North West"),
			NSLocalizedString("CARDINAL_DIRECTION_NW",   bundle: bundle, value: "NW",  comment: "Abbreviation for North West"),
			NSLocalizedString("CARDINAL_DIRECTION_NNW",  bundle: bundle, value: "NNW", comment: "Abbreviation for North North West")
		]
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
