//
//  ObjectMapper+AirMap.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/30/16.
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

import ObjectMapper

class StringToIntTransform: TransformType {
	
	typealias Object = Int
	typealias JSON = String
	
	func transformFromJSON(_ value: Any?) -> Int? {
		if let string = value as? String {
			if let double = Double(string) {
				return Int(round(double))
			}
		}
		return nil
	}
	
	func transformToJSON(_ value: Int?) -> String? {
		if let int = value {
			return String(int)
		}
		return nil
	}
}

class StringToDoubleTransform: TransformType {
	
	typealias Object = Double
	typealias JSON = String
	
	func transformFromJSON(_ value: Any?) -> Double? {
		if let string = value as? String {
			return Double(string)
		}
		return nil
	}
	
	func transformToJSON(_ value: Double?) -> String? {
		if let double = value {
			return String(double)
		}
		return nil
	}
}

public class GeoJSONToAirMapGeometryTransform: TransformType {
	
	public typealias Object = AirMapGeometry
	public typealias JSON = [String: Any]
	
	public init() {}
	
	public func transformFromJSON(_ value: Any?) -> AirMapGeometry? {

		guard let geometry = value as? JSON, let type = geometry["type"] as? String else { return nil }

		switch type {
		case "Polygon":
			guard let points = geometry["coordinates"] as? [[[Double]]]  else { return nil }
				
			let coords: [[Coordinate2D]] = points
				.map { poly in poly.map { ($0[1], $0[0]) }
					.map(Coordinate2D.init)
				}

			return AirMapPolygon(coordinates: coords)

		case "LineString":
			guard let pointString = geometry["coordinates"] as? [[Double]] else { return nil }
			let coords: [Coordinate2D] = pointString
				.map { point in
					Coordinate2D(latitude: point[0], longitude: point[1])
				}
			return AirMapPath(coordinates: coords)
			
		case "Point":
			guard let points = geometry["coordinates"] as? [Double], points.count == 2 else { return nil }
			let coord: Coordinate2D = Coordinate2D(latitude: points[1], longitude: points[0])
			return AirMapPoint(coordinate: coord)
		
		default:
			return nil
		}
	}
	
	public func transformToJSON(_ value: AirMapGeometry?) -> JSON? {

		return value?.params()
	}
}
