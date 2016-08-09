//
//  AirMapFlightRadiusAnnotation.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/20/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Mapbox
import CoreLocation

class AirMapFlightRadiusAnnotation: MGLPolygon {

	class func polygon(location: CLLocationCoordinate2D, radius: CLLocationDistance) -> MGLPolygon {
		
		var coordinates = polygonCircleForCoordinates(location, withMeterRadius: radius)
		return MGLPolygon(coordinates: &coordinates, count: UInt(coordinates.count))
	}
	
	private class func polygonCircleForCoordinates(coordinate: CLLocationCoordinate2D, withMeterRadius: CLLocationDistance) -> [CLLocationCoordinate2D] {
		
		let degreesBetweenPoints = 4.0
		let numberOfPoints = floor(360.0 / degreesBetweenPoints)
		let distRadians: Double = withMeterRadius / 6371000.0
		let centerLatRadians: Double = coordinate.latitude * M_PI / 180
		let centerLonRadians: Double = coordinate.longitude * M_PI / 180
		
		return Array(0..<Int(numberOfPoints)).map { index in
			
			let degrees = Double(index) * Double(degreesBetweenPoints)
			let radians = degrees * M_PI / 180
			let pointLatRadians = asin(sin(centerLatRadians) * cos(distRadians) + cos(centerLatRadians) * sin(distRadians) * cos(radians))
			let pointLonRadians = centerLonRadians + atan2(sin(radians) * sin(distRadians) * cos(centerLatRadians), cos(distRadians) - sin(centerLatRadians) * sin(pointLatRadians))
			let latitude = pointLatRadians * 180 / M_PI
			let longitude = pointLonRadians * 180 / M_PI

			return CLLocationCoordinate2DMake(latitude, longitude)
		}
	}

}