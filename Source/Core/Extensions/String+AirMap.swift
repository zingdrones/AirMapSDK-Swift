//
//  String+AirMap.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/2/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

extension String {

	var urlEncoded: String {
		return addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? self
	}

	static func coordinateString(_ latitude: Double, longitude: Double) -> String {

		var latSeconds = Int(latitude * 3600)
		let latDegrees = latSeconds / 3600
		latSeconds = abs(latSeconds % 3600)
		let latMinutes = latSeconds / 60
		latSeconds %= 60
		var longSeconds = Int(longitude * 3600)
		let longDegrees = longSeconds / 3600
		longSeconds = abs(longSeconds % 3600)
		let longMinutes = longSeconds / 60
		longSeconds %= 60
		return String(format:"%d°%d'%d\"%@ %d°%d'%d\"%@",
		              abs(latDegrees),
		              latMinutes,
		              latSeconds, {return latDegrees >= 0 ? "N" : "S"}(),
		              abs(longDegrees),
		              longMinutes,
		              longSeconds, {return longDegrees >= 0 ? "E" : "W"}() )
	}

}
