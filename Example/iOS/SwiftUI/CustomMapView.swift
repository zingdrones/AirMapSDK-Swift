//
//  CustomMapView.swift
//  AirMapSDK-Example-iOS
//
//  Created by Michael Odere on 10/29/19.
//  Copyright © 2019 AirMap, Inc. All rights reserved.
//

import AirMap
import Mapbox
import SwiftUI

private struct CustomMapView: UIViewRepresentable {
	private let mapView: AirMapMapView = AirMapMapView(frame: .zero)
	
	func makeUIView(context: UIViewRepresentableContext<CustomMapView>) -> AirMapMapView {
		let token = AirMap.configuration.mapboxAccessToken!
		MGLAccountManager.accessToken = token
		mapView.delegate = context.coordinator
		return mapView
	}
	
	func updateUIView(_ uiView: AirMapMapView, context: UIViewRepresentableContext<CustomMapView>) {}
	
	func makeCoordinator() -> CustomMapView.Coordinator {
		Coordinator()
	}
	
	func styleURL(_ styleURL: URL) -> CustomMapView {
		mapView.styleURL = styleURL
		return self
	}
	
	func centerCoordinate(_ centerCoordinate: CLLocationCoordinate2D) -> CustomMapView {
		mapView.centerCoordinate = centerCoordinate
		return self
	}
	
	func zoomLevel(_ zoomLevel: Double) -> CustomMapView {
		mapView.zoomLevel = zoomLevel
		return self
	}
	
	final class Coordinator: NSObject, AirMapMapViewDelegate {
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
					lineLayer.lineColor = NSExpression(forConstantValue: color)
				}
				// removed dashed lines
				lineLayer.lineDashPattern = nil
				
			case let fillLayer as MGLFillStyleLayer:
				if let color = color {
					fillLayer.fillColor = NSExpression(forConstantValue: color)
				}
				
			default:
				break
			}
		}
		
	}
}

struct CustomMapContentView: View {
	
	var body: some View {
		CustomMapView()
			.centerCoordinate(CLLocationCoordinate2D(latitude: 51.474, longitude: -0.133))
			.zoomLevel(9.5)
			.navigationBarTitle(Text(verbatim: "Simple Map"), displayMode: .inline)
			.edgesIgnoringSafeArea(.all)
	}
}

struct CustomMapContentView_Previews: PreviewProvider {
	static var previews: some View {
		SimpleMapContentView()
	}
}


//import UIKit
//import AirMap
//import Mapbox
//
//class CustomStylingMapViewController: UIViewController {
//
//	var mapView: AirMapMapView!
//
//	override func viewDidLoad() {
//		super.viewDidLoad()
//
//		// create a new map and add it to the view hierarchy
//		// optionally can be added via a storyboard in Interface Builder
//		mapView = AirMapMapView(frame: view.bounds)
//		mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//		view.addSubview(mapView)
//
//		// set the visual style
//		mapView.theme = .dark
//
//		// set the map's ruleset behavior
//		mapView.rulesetConfiguration = .automatic
//
//		// set the map location to London, UK
//		mapView.centerCoordinate = CLLocationCoordinate2D(latitude: 51.474, longitude: -0.133)
//		mapView.zoomLevel = 9.5
//
//		// register as the delegate to receive callbacks
//		mapView.delegate = self
//	}
//}
//
//extension CustomStylingMapViewController: AirMapMapViewDelegate {
//
//	func airMapMapViewDidAddAirspaceType(mapView: AirMapMapView, ruleset: AirMapRuleset, airspaceType: AirMapAirspaceType, layer: inout MGLStyleLayer) {
//
//		let color: UIColor?
//
//		switch airspaceType {
//		case .tfr, .fire, .wildfire, .specialUse:
//			color = UIColor(hue: 0.85, saturation: 0.8, brightness: 1.0, alpha: 1.0)
//		case .notam:
//			color = UIColor(hue: 0.15, saturation: 0.9, brightness: 0.8, alpha: 1.0)
//		case .airport, .heliport:
//			color = .red
//		case .controlledAirspace:
//			color = .orange
//		case .hospital, .school, .powerPlant, .city:
//			color = .brown
//		case .amaField:
//			color = .green
//		default:
//			color = nil
//		}
//
//		switch layer {
//
//		case let lineLayer as MGLLineStyleLayer:
//			if let color = color {
//				lineLayer.lineColor = NSExpression(forConstantValue: color)
//			}
//			// removed dashed lines
//			lineLayer.lineDashPattern = nil
//
//		case let fillLayer as MGLFillStyleLayer:
//			if let color = color {
//				fillLayer.fillColor = NSExpression(forConstantValue: color)
//			}
//
//		default:
//			break
//		}
//	}
//
//}
