//
//  SimpleMapViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 12/11/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import UIKit
import AirMap

class SimpleMapViewController: UIViewController {
	
	var mapView: AirMapMapView!
	
	override func viewDidLoad() {
		super.viewDidLoad()

		// create a new map and add it to the view hierarchy
		// optionally can be added via a storyboard in Interface Builder
		mapView = AirMapMapView(frame: view.bounds)
		mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		view.addSubview(mapView)

		// set the visual style
		mapView.theme = .light

        // set the map's ruleset behavior
        mapView.rulesetConfiguration = .automatic
        
        // alternatively, the map can be configured with a list preferred ruleset ids
//        map.rulesetConfiguration = .dynamic(preferredRulesetIds: ["usa_part_107"], enableRecommendedRulesets: true)

		// set the map location to Santa Monica, California
		mapView.centerCoordinate = CLLocationCoordinate2D(latitude: 34.023, longitude: -118.484)
		mapView.zoomLevel = 10

		mapView.delegate = self

	}
}

extension SimpleMapViewController: AirMapMapViewDelegate {
	
	func airMapMapViewJurisdictionsDidChange(mapView: AirMapMapView, jurisdictions: [AirMapJurisdiction]) {
		
		// Print out all the jurisdictions that intersect the map's view port
		let jurisdictionNames = jurisdictions.map { $0.name }
		print("Jurisdictions:",  jurisdictionNames)
	}
	
	func airMapMapViewRegionDidChange(mapView: AirMapMapView, jurisdictions: [AirMapJurisdiction], activeRulesets: [AirMapRuleset]) {
		
		// Print out all the active rulesets the map is configured with
		print("Active Rulesets:", activeRulesets.identifiers )
	}
	
}
