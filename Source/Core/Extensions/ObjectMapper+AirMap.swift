//
//  ObjectMapper+AirMap.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/30/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

class StringToIntTransform: TransformType {
	typealias Object = Int
	typealias JSON = String
	
	func transformFromJSON(value: AnyObject?) -> Int? {
		if let string = value as? String {
			return Int(string)
		}
		return nil
	}
	
	func transformToJSON(value: Int?) -> String? {
		if let int = value {
			return String(int)
		}
		return nil
	}
}

class StringToDoubleTransform: TransformType {
	typealias Object = Double
	typealias JSON = String
	
	func transformFromJSON(value: AnyObject?) -> Double? {
		if let string = value as? String {
			return Double(string)
		}
		return nil
	}
	
	func transformToJSON(value: Double?) -> String? {
		if let double = value {
			return String(double)
		}
		return nil
	}
}

class CsvToArrayTransform: TransformType {
	typealias Object = [String]
	typealias JSON = String
	
	func transformFromJSON(value: AnyObject?) -> [String]? {
		if let string = value as? String {
			return string.componentsSeparatedByString(",")
		}
		return nil
	}
	
	func transformToJSON(value: [String]?) -> String? {
		if let array = value {
			return array.joinWithSeparator(",")
		}
		return nil
	}
}


class geoJSONToAirMapGeometryTransform: TransformType {
	typealias Object = AirMapGeometry
	typealias JSON = String
	
	func transformFromJSON(value: AnyObject?) -> AirMapGeometry? {
		
		if let geometry = value as? [String : AnyObject] {
			if let type = geometry["type"] as? String {
				switch type {
				case "Polygon":
					return geometry["coordinates"] as? AirMapPolygon
				case "Point":
					return geometry["coordinates"] as? AirMapPoint
				case "LineString":
					return geometry["coordinates"] as? AirMapPath
				default:
					return nil
				}
			}
		}
		
		return nil
	}
	
	func transformToJSON(value: AirMapGeometry?) -> String? {
		if let obj = value {
			return obj.description
		}
		return nil
	}
}
