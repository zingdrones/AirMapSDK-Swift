//
//  AirMapFlight+Mapbox.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/5/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Mapbox
import SwiftTurf

protocol AnnotationRepresentable {
	var geometry: AirMapGeometry? { get }
}

extension AnnotationRepresentable {
	
	public func annotationRepresentations() -> [MGLAnnotation]? {
		
		guard let geometry = self.geometry else { return nil }
		
		switch geometry {
			
		case .point(let geo, let buffer):
			let point = Point(geometry: geo)
			let bufferedPoint = SwiftTurf.buffer(point, distance: buffer, units: .Meters)
			
			guard var coordinates = bufferedPoint?.geometry.first
				else { return nil }
			
			let circlePolygon = MGLPolygon(coordinates: &coordinates, count: UInt(coordinates.count))
			let circleLine = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
			return [circlePolygon, circleLine]
			
		case .path(var geo, let buffer):

			let lineString = LineString(geometry: geo)
			
			guard let bufferedCoordinates = SwiftTurf.buffer(lineString, distance: buffer)?.geometry else {
				return nil
			}
			var outerCoordinates = bufferedCoordinates.first!
			
			var interiorPolygons: [MGLPolygon] = bufferedCoordinates.map {
				var coordinates = $0
				return MGLPolygon(coordinates: &coordinates, count: UInt(geo.count))
			}
			interiorPolygons.removeFirst()
			
			let bufferPolygon = MGLPolygon(coordinates: &outerCoordinates, count: UInt(outerCoordinates.count), interiorPolygons: interiorPolygons)
			let pathPolyline = MGLPolyline(coordinates: &geo, count: UInt(geo.count))
			
			return [bufferPolygon, pathPolyline]
			
		case .polygon(let geo):
			
			guard geo.count > 0 && geo.first!.count >= 3 else {
				return nil
			}
			
			var outer = geo.first!
			outer.append(outer.first!)
			
			let fill: MGLPolygon
			let strokes: [MGLAnnotation]
			
			if geo.count == 1 {
				fill = MGLPolygon(coordinates: &outer, count: UInt(outer.count))
				strokes = [MGLPolyline(coordinates: &outer, count: UInt(outer.count))]
			} else {
				let interiorPolygons: [MGLPolygon] = geo[1..<geo.count].map {
					var coords = $0
					return MGLPolygon(coordinates: &coords, count: UInt(coords.count))
				}
				fill = MGLPolygon(coordinates: &outer, count: UInt(outer.count), interiorPolygons: interiorPolygons)
				strokes = interiorPolygons.map { polygon in
					MGLPolyline(coordinates: polygon.coordinates, count: UInt(interiorPolygons.count))
				}
			}
			
			return [fill] + strokes
		}		
	}
	
}

