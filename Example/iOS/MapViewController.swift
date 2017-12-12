//
//  ViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 06/27/2016.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit
import AirMap
import Mapbox

class AdvancedMapViewController: UIViewController {

	// Mapview is instantiated via the storyboard
	@IBOutlet weak var mapView: AirMapMapView!
}

// MARK: - View Lifecycle

extension AdvancedMapViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Restore any previously saved ruleset preferences
//		preferredRulesetIds = persistedRulesetPreferences()
	}
}

// MARK: - Navigation

extension AdvancedMapViewController {
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		// Handle the segue that displays the rulesets selector
		if segue.identifier == "presentRulesets" {
			
			// Get all jurisdictions from the map
			// Alternatively you can call AirMap.getJurisdictions(...) for a given area if you are not using Mapbox
			let jurisdictions = mapView.jurisdictions
			
			let nav = segue.destination as! UINavigationController
			let rulesetsVC = nav.viewControllers.first as! RulesetsViewController
			rulesetsVC.availableJurisdictions = jurisdictions
//			rulesetsVC.preferredRulesets = preferredRulesets

			
			// Set ourselves as the delegate so that we can be notified of ruleset selection
			rulesetsVC.delegate = self
		}
		
		// Handle the segue that displays the advisories for a given area and rulesets
		if segue.identifier == "presentAdvisories" {
			
			let nav = segue.destination as! UINavigationController
			let advisoriesVC = nav.viewControllers.first as! AdvisoriesViewController
			
			// Construct an AirMapPolygon from the bounding box of the visible area
			advisoriesVC.area = mapView.visibleCoordinateBounds.geometry
			advisoriesVC.rulesets = mapView.activeRulesets
		}
	}
	
	@IBAction func unwindToMap(_ segue: UIStoryboardSegue) {
		// Interface Builder storyboard unwind hook; keep
	}
}

// MARK: - Instance Methods

extension AdvancedMapViewController {
	
	private static let rulesetPreferenceKey = "com.airmap.sdk.ruleset_ids"
	
	/// Persist the given ruleset identifiers to the user's shared preferences
	///
	/// - Parameter rulesetIds: The ruleset identifiers to persist
	private func persistPreferences(for rulesetIds: [String]) {
		UserDefaults.standard.set(rulesetIds, forKey: AdvancedMapViewController.rulesetPreferenceKey)
	}
	
	/// Fetch the persisted ruleset identifers
	///
	/// - Returns: A array of preferred ruleset identifiers
	private func persistedRulesetPreferences() -> [String] {
		return UserDefaults.standard.value(forKey: AdvancedMapViewController.rulesetPreferenceKey) as? [String] ?? []
	}
}

// MARK: - RulesetsViewControllerDelegate

extension AdvancedMapViewController: RulesetsViewControllerDelegate {
	
	func rulesetsViewControllerDidSelect(_ rulesets: [AirMapRuleset]) {
		
		// Update the map with the selected rulesets
		mapView.configuration = .manual(rulesets: rulesets)
	}
}

// MARK: - AirMapMapViewDelegate

extension AdvancedMapViewController: AirMapMapViewDelegate {

	func airMapMapViewJurisdictionsDidChange(mapView: AirMapMapView, jurisdictions: [AirMapJurisdiction]) {
		
	}
	
	func airMapMapViewRegionDidChange(mapView: AirMapMapView, jurisdictions: [AirMapJurisdiction], activeRulesets: [AirMapRuleset]) {
		
	}
	
}
