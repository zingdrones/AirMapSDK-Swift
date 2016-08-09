//
//  AirMapFlightPlanViewController+Mapbox.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/20/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Mapbox

extension AirMapFlightPlanViewController: MGLMapViewDelegate {

	func mapView(mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {

		let color: UIColor

		if let status = navigationController?.status.value {
			switch status.advisoryColor {
			case .Gray:    color = .airMapGray()
			case .Red:     color = .airMapRed()
			case .Yellow:  color = .airMapYellow()
			case .Green:   color = .airMapGreen()
			}
		} else {
			color = .airMapGray()
		}
		return color.colorWithAlphaComponent(0.5)
	}

	func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
		return .clearColor()
	}

	func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {

		if let flightIcon = AirMapImage.flightIcon(AirMapFlight.FlightType.Active) {
			return MGLAnnotationImage(image: flightIcon, reuseIdentifier: "icon")
		}
		return nil
	}

}
