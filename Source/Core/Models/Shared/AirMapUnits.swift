//
//  AirMapUnits.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 2/7/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation

public enum DistanceUnits {
	case metric
	case imperial
	
	static let metersPerFoot: Feet = 0.3048
}

public enum TemperatureUnits {
	case celcius
	case fahrenheit
}

public typealias Feet = Double
public typealias Miles = Double
public typealias Meters = Double


#if os(Linux)
	
	public typealias Coordinate2D = AirMapLocationCoordinate2D
	
	public struct AirMapLocationCoordinate2D {
		
		let latitude: Double
		let longitude: Double
		
		var isValid: Bool {
			return (latitude <= 90 && latitude >= -90) && (longitude <= 180 && longitude >= -180)
		}
	}
	
#else
	
	import CoreLocation
	
	public typealias Coordinate2D = CLLocationCoordinate2D
	
	extension CLLocationCoordinate2D {
		
		var isValid: Bool {
			return CLLocationCoordinate2DIsValid(self)
		}
	}
	
#endif
