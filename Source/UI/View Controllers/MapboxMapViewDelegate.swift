//
//  MapboxMapViewDelegate.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/20/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Mapbox

class AirMapMapboxMapViewDelegate: NSObject, MGLMapViewDelegate {
	
	weak var controlPointDelegate: ControlPointDelegate?
	
	
	func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
		
		if let controlPoint = annotation as? ControlPoint {
			if let controlPointView = mapView.dequeueReusableAnnotationView(withIdentifier: String(describing: controlPoint.type)) as? ControlPointView {
				return controlPointView
			} else {
				let controlPointView = ControlPointView(type: controlPoint.type)
				controlPointView.delegate = controlPointDelegate
				return controlPointView
			}
		}
		
		if annotation is InvalidIntersection {
			if let invalidIntersectionView = mapView.dequeueReusableAnnotationView(withIdentifier: String(describing: InvalidIntersectionView.self)) as? InvalidIntersectionView {
				return invalidIntersectionView
			} else {
				return InvalidIntersectionView()
			}
		}
		
		return nil
	}
	
}
