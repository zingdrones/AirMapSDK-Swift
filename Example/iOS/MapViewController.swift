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
import Mapbox

/// Example of configuring an AirMapMapView using an array of known AirMapRulesets. This view controller conforms to MGLMapViewDelegate and whenever the map region changes, the map is queried for the jurisdictions that intersect the visible area.
class MapViewController: UIViewController {
	
	@IBOutlet weak var mapView: AirMapMapView!
	
	private var preferredRulesetIds = [String]()
	private var activeRulesets = [AirMapRuleset]()
	
	private static let rulesetPreferenceKey = "airmap_ruleset_ids"
	
	// MARK: - View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()

		// Restore any previously saved ruleset preferences
		preferredRulesetIds = persistedRulesetPreferences()
	}
	
	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		// Handle the segue that displays the rulesets selector
		if segue.identifier == "presentRulesets" {
			
			// Get all visible jurisdictions from the map
			// Alternatively you can call AirMap.getJurisdictions(...) for a given area if you are not using Mapbox
			let jurisdictions = mapView.visibleJurisdictions()
			
			// Take all jurisdictions and determine which should be enabled
			let resolvedRuleset = self.resolvedRulesets(with: preferredRulesetIds, from: jurisdictions)
			
			// Collect only the elective rulesets (optional + pick ones)
			let preferredRulesets = resolvedRuleset.filter { $0.type == .optional || $0.type == .pickOne }

			let nav = segue.destination as! UINavigationController
			let rulesetsVC = nav.viewControllers.first as! RulesetsViewController
			rulesetsVC.availableJurisdictions = jurisdictions
			rulesetsVC.preferredRulesets = preferredRulesets
		}
		
		// Handle the segue that displays the advisories for a given area and rulesets
		if segue.identifier == "presentAdvisories" {
			
			let nav = segue.destination as! UINavigationController
			let advisoriesVC = nav.viewControllers.first as! AdvisoriesViewController
			
			// Construct an AirMapPolygon from the bounding box of the visible area
			advisoriesVC.area = mapView.visibleCoordinateBounds.geometry
			advisoriesVC.rulesets = activeRulesets
		}
	}
	
	@IBAction func unwindFromRulesets(_ segue: UIStoryboardSegue) {
		guard let rulesetsVC = segue.source as? RulesetsViewController else { return }

		// Update the local reference to the user's preferred rulesets
		preferredRulesetIds = rulesetsVC.preferredRulesets.map { $0.id }
		
		// Save the selected rulesets to the user defaults
		persistPreferences(for: preferredRulesetIds)
		
		// Update the actively selected rulesets
		updateActiveRulesets()
	}
	
	// MARK: - Private Methods
	
	/// Update the active rulesets using the preferred rulesets and the jurisdictions on the map
	fileprivate func updateActiveRulesets() {
		activeRulesets = resolvedRulesets(with: preferredRulesetIds, from: mapView.visibleJurisdictions())
		mapView.configure(rulesets: activeRulesets)
	}
	
	/// Persist the given ruleset identifiers to the user's shared preferences
	///
	/// - Parameter rulesetIds: The ruleset identifiers to persist
	private func persistPreferences(for rulesetIds: [String]) {
		UserDefaults.standard.set(rulesetIds, forKey: MapViewController.rulesetPreferenceKey)
	}
	
	/// Fetch the persisted ruleset identifers
	///
	/// - Returns: A array of preferred ruleset identifiers
	private func persistedRulesetPreferences() -> [String] {
		return UserDefaults.standard.value(forKey: MapViewController.rulesetPreferenceKey) as? [String] ?? []
	}
	
	/// Take the user's rulesets preference and resolve which rulesets should be selected from the available jurisdictions
	///
	/// - Parameters:
	///   - preferredRulesetIds: An array of rulesets ids, if any, that the user has previously selected
	///   - availableJurisdictions: An array of jurisdictions for the area of operation
	/// - Returns: A resolved array of rulesets taking into account the user's .optional and .pickOne selection preference
	private func resolvedRulesets(with preferredRulesetIds: [String], from availableJurisdictions: [AirMapJurisdiction]) -> [AirMapRuleset] {
		
		var rulesets = [AirMapRuleset]()
		
		// Always include the required rulesets (e.g. TFRs, restricted areas, etc)
		rulesets += availableJurisdictions.requiredRulesets
		
		// If the preferred rulesets contains an .optional ruleset, add it to the array
		rulesets += availableJurisdictions.optionalRulesets.filter({ preferredRulesetIds.contains($0.id) })
		
		// For each jurisdiction, determine if a preferred .pickOne has been selected otherwise take the default .pickOne
		for jurisdiction in availableJurisdictions {
			guard let defaultPickOneRuleset = jurisdiction.defaultPickOneRuleset else { continue }
			if let preferredPickOne = jurisdiction.pickOneRulesets.first(where: { preferredRulesetIds.contains($0.id) }) {
				rulesets.append(preferredPickOne)
			} else {
				rulesets.append(defaultPickOneRuleset)
			}
		}
		
		return rulesets
	}
}

// MARK: - MGLMapViewDelegate

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

// MARK: - Mapbox Convenience Extensions

extension MGLCoordinateBounds {

	// Convert the bounding box into a polygon; remembering to close the polygon by passing the first point again
	var geometry: AirMapPolygon {
		let nw = CLLocationCoordinate2D(latitude: ne.latitude, longitude: sw.longitude)
		let se = CLLocationCoordinate2D(latitude: sw.latitude, longitude: ne.longitude)
		let coordinates = [nw, ne, se, sw, nw]
		return AirMapPolygon(coordinates: [coordinates])
	}
}
