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
	
	var map: AirMapMapView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	
		setupMap()
	}
	
	private func setupMap() {
		
		// create a new map and add it to the view hierarchy
		// optionally can be added via a storyboard in Interface Builder
		map = AirMapMapView(frame: view.bounds)
		map.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		view.addSubview(map)
		
		// set the visual style
		map.theme = .standard
		
		// set the map's ruleset behavior
		map.configuration = .dynamic(preferredRulesetIds: ["usa_part_107"], enableRecommendedRulesets: true)

		// alternatively, the map can be configured automatically without any preferred rulesets
//		map.configuration = .automatic

		// set the location and zoom level
		map.latitude = 34.1
		map.longitude = -118.4
		map.zoomLevel = 10
		
		// register as the delegate to receive callbacks
		map.delegate = self
	}
}

extension SimpleMapViewController: AirMapMapViewDelegate {
	
	func airMapMapViewJurisdictionsDidChange(mapView: AirMapMapView, jurisdictions: [AirMapJurisdiction]) {
		
		// Print out all the jurisdictions that intersect the map's view port
		let jurisdictionNames = jurisdictions.map { $0.name }
		print("JURISDICTIONS: ",  jurisdictionNames)
	}
	
	func airMapMapViewRegionDidChange(mapView: AirMapMapView, jurisdictions: [AirMapJurisdiction], activeRulesets: [AirMapRuleset]) {
		
		// Print out all the active rulesets the map is configured with
		let activeRulesetNames = jurisdictions.map { $0.name }
		print("ACTIVE RULESETS: ", activeRulesetNames )
	}
	
}
