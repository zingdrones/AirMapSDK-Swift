//
//  AirMapApiData.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/20/16.
/*
Copyright 2018 AirMap, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
//

import Foundation
import SwiftTurf

public protocol AirMapGeometry {
	var type: AirMapFlightGeometryType { get }
	func params() -> [String: Any]
}

extension AirMapGeometry {
	
	var geoJSONDictionary: GeoJSONDictionary {
		switch self {
		case let point as AirMapPoint:
			return Point(geometry: point.coordinate).geoJSONRepresentation()
		case let polygon as AirMapPolygon:
			return Polygon(geometry: polygon.coordinates).geoJSONRepresentation()
		case let path as AirMapPath:
			return LineString(geometry: path.coordinates).geoJSONRepresentation()
		default:
			fatalError()
		}
	}
}
