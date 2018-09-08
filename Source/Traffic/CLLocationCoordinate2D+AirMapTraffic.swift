//
//  CLLocationCoordinate2D+AirMapTraffic.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 2/21/17.
//  Copyright 2018 AirMap, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
