//
//  CoreLocation+AirMap.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/19/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import CoreLocation

extension CLLocationCoordinate2D {

	static func polygonCircleForCoordinates(_ coordinate: CLLocationCoordinate2D, withMeterRadius: Double) -> [CLLocationCoordinate2D] {
		
		let degreesBetweenPoints = 4.0
		let numberOfPoints = floor(360.0 / degreesBetweenPoints)
		let distRadians: Double = withMeterRadius / 6371000.0
		let centerLatRadians: Double = coordinate.latitude * .pi / 180
		let centerLonRadians: Double = coordinate.longitude * .pi / 180
		var coordinates = [CLLocationCoordinate2D]()
		
		for index in 0..<Int(numberOfPoints) {
			let degrees: Double = Double(index) * Double(degreesBetweenPoints)
			let degreeRadians: Double = degrees * .pi / 180
			let pointLatRadians: Double = asin(sin(centerLatRadians) * cos(distRadians) + cos(centerLatRadians) * sin(distRadians) * cos(degreeRadians))
			let pointLonRadians: Double = centerLonRadians + atan2(sin(degreeRadians) * sin(distRadians) * cos(centerLatRadians), cos(distRadians) - sin(centerLatRadians) * sin(pointLatRadians))
			let pointLat: Double = pointLatRadians * 180 / .pi
			let pointLon: Double = pointLonRadians * 180 / .pi
			let point: CLLocationCoordinate2D = CLLocationCoordinate2DMake(pointLat, pointLon)
			coordinates.append(point)
		}
		
		return coordinates
	}

}
