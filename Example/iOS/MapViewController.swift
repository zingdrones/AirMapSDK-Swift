//
//  ViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 06/27/2016.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit
import AirMap
import RxSwift

class MapViewController: UIViewController {
	
	@IBOutlet weak var mapView: AirMapMapView!
	
	private var preferredRulesetIds = [String]()
	
	private var activeRulesets = [AirMapRuleset]() {
		didSet { mapView.configure(rulesets: activeRulesets) }
	}
	
	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		if segue.identifier == "presentRulesets" {
			let jurisdictions = mapView.visibleJurisdictions()
			let resolvedRuleset = AirMapJurisdiction.resolvedRulesets(with: preferredRulesetIds, from: jurisdictions)
			let preferredRulesets = resolvedRuleset.filter { $0.type == .optional || $0.type == .pickOne }

			let nav = segue.destination as! UINavigationController
			let rulesetsVC = nav.viewControllers.first as! RulesetsViewController
			rulesetsVC.availableJurisdictions = jurisdictions
			rulesetsVC.preferredRulesets = preferredRulesets
		}
		
		if segue.identifier == "presentAdvisories" {
			let nav = segue.destination as! UINavigationController
			let advisoriesVC = nav.viewControllers.first as! AdvisoriesViewController
			advisoriesVC.rulesets = activeRulesets
			advisoriesVC.area = mapView.visibleCoordinateBounds.geometry
		}
	}
	
	@IBAction func unwindFromRulesets(_ segue: UIStoryboardSegue) {
		guard let rulesetsVC = segue.source as? RulesetsViewController else { return }
		preferredRulesetIds = rulesetsVC.preferredRulesets.map { $0.id }
		updateActiveRulesets()
	}
	
	// MARK: - Configuration
	
	/// Update the active rulesets using the preferred rulesets and the jurisdictions on the map
	func updateActiveRulesets() {
		activeRulesets = AirMapJurisdiction.resolvedRulesets(with: preferredRulesetIds, from: mapView.visibleJurisdictions())
	}
	
}

// MARK: - MGLMapViewDelegate

import Mapbox

extension MapViewController: MGLMapViewDelegate {
	
	// When the map finished loading the initial style, configure it with rulesets
	func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
		updateActiveRulesets()
	}
	
	// Any time the map is repositioned, reconfigure the map
	func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
		updateActiveRulesets()
	}

}

import CoreLocation

extension MGLCoordinateBounds {

	// Convert the bounding box into a polygon; remembering to close the polygon by passing the first point again
	var geometry: AirMapPolygon {
		let nw = CLLocationCoordinate2D(latitude: ne.latitude, longitude: sw.longitude)
		let se = CLLocationCoordinate2D(latitude: sw.latitude, longitude: ne.longitude)
		let coordinates = [nw, ne, se, sw, nw]
		return AirMapPolygon(coordinates: [coordinates])
	}
}
