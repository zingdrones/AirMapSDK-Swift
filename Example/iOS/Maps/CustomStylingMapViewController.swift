//
//  CustomStylingMapViewController.swift
//  AirMapSDK-Example-iOS
//
//  Created by Adolfo Martinelli on 12/22/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import UIKit
import AirMap
import Mapbox

class CustomStylingMapViewController: UIViewController {
	
	var map: AirMapMapView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// create a new map and add it to the view hierarchy
		// optionally can be added via a storyboard in Interface Builder
		map = AirMapMapView(frame: view.bounds)
		map.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		view.addSubview(map)
		
		// set the visual style
		map.theme = .dark
		
		// set the map's ruleset behavior
		map.configuration = .automatic
		
		// set the map location to London, UK
		map.centerCoordinate = CLLocationCoordinate2D(latitude: 51.474, longitude: -0.133)
		map.zoomLevel = 9.5
		
		// register as the delegate to receive callbacks
		map.delegate = self
	}
}

extension CustomStylingMapViewController: AirMapMapViewDelegate {
	
	func airMapMapViewDidAddAirspaceType(mapView: AirMapMapView, ruleset: AirMapRuleset, airspaceType: AirMapAirspaceType, layer: inout MGLStyleLayer) {
		
		let color: UIColor?
		
		switch airspaceType {
		case .tfr, .fire, .wildfire, .specialUse:
			color = UIColor(hue: 0.85, saturation: 0.8, brightness: 1.0, alpha: 1.0)
		case .notam:
			color = UIColor(hue: 0.15, saturation: 0.9, brightness: 0.8, alpha: 1.0)
		case .airport, .heliport:
			color = .red
		case .controlledAirspace:
			color = .orange
		case .hospital, .school, .powerPlant, .city:
			color = .brown
		case .amaField:
			color = .green
		default:
			color = nil
		}
		
		switch layer {
			
		case let lineLayer as MGLLineStyleLayer:
			if let color = color {
				lineLayer.lineColor = MGLStyleValue(rawValue: color)
			}
			// removed dashed lines
			lineLayer.lineDashPattern = nil
			
		case let fillLayer as MGLFillStyleLayer:
			if let color = color {
				fillLayer.fillColor = MGLStyleValue(rawValue: color)
			}

		default:
			break
		}
	}
	
}
