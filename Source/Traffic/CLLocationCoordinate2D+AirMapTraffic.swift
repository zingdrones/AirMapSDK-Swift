//
//  CLLocationCoordinate2D+AirMapTraffic.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 2/21/17.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

extension Coordinate2D {

	public var formattedString: String {

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
		
		let north = AirMapTrafficServiceUtils.directionFromBearing(000)
		let south = AirMapTrafficServiceUtils.directionFromBearing(180)
		let east  = AirMapTrafficServiceUtils.directionFromBearing(090)
		let west  = AirMapTrafficServiceUtils.directionFromBearing(270)
		
		return String(format:"%d° %d' %d\" %@, %d° %d' %d\" %@",
					  abs(latDegrees),
					  latMinutes,
					  latSeconds, (latDegrees >= 0 ? north : south),
					  abs(longDegrees),
					  longMinutes,
					  longSeconds, (longDegrees >= 0 ? east : west) )
	}

}
