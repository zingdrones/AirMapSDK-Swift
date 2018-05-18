//
//  AdvancedMapViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 06/27/2016.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit
import AirMap

/// Example implementation that shows how to configure the map with known rulesets
class AdvancedMapViewController: UIViewController {
	
	// this map view is instantiated via the storyboard
	@IBOutlet weak var mapView: AirMapMapView!

	// track all available jurisdictions
	private var jurisdictions: [AirMapJurisdiction] = []

	// track the user's preference for rulesets (restored from and saved to UserDefaults)
	private var preferredRulesetIds: Set<AirMapRulesetId> = UserDefaults.standard.preferredRulesetIds() {
		didSet {
			UserDefaults.standard.store(preferredRulesetIds)
		}
	}

	// track the active rulesets
	private var activeRulesets: [AirMapRuleset] = [] {
		didSet {
			// update the map with the latest rulesets
			mapView.rulesetConfiguration = .manual(rulesets: activeRulesets)
		}
	}
}

// MARK: - View Lifecycle

extension AdvancedMapViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// register as the map's delegate
		mapView.delegate = self
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		//FIXME: The styles won't load unless this is called
		self.mapView.delegate?.mapViewRegionIsChanging?(self.mapView)
	}
}

// MARK: - Navigation

extension AdvancedMapViewController {
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		// Handle the segue that displays the rulesets selector
		if segue.identifier == "presentRulesets" {
			
			let nav = segue.destination as! UINavigationController
			let rulesetsVC = nav.viewControllers.first as! RulesetsViewController
			rulesetsVC.availableJurisdictions = jurisdictions
			rulesetsVC.preferredRulesets = activeRulesets
			
			// Set ourselves as the delegate so that we can be notified of ruleset selection
			rulesetsVC.delegate = self
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
}

// MARK: - AirMapMapViewDelegate

extension AdvancedMapViewController: AirMapMapViewDelegate {
	
	func airMapMapViewJurisdictionsDidChange(mapView: AirMapMapView, jurisdictions: [AirMapJurisdiction]) {
		
		self.jurisdictions = jurisdictions

		// Handle updates to the map's jurisdictions and resolve which rulesets should be active based on user preference
		activeRulesets = AirMapRulesetResolver.resolvedActiveRulesets(with: Array(preferredRulesetIds), from: jurisdictions, enableRecommendedRulesets: false)
	}
}

// MARK: - RulesetsViewControllerDelegate

extension AdvancedMapViewController: RulesetsViewControllerDelegate {
	
	func rulesetsViewControllerDidSelect(_ rulesets: [AirMapRuleset]) {
		
		let newlySelected = Set(rulesets)
		let previouslySelected = Set(activeRulesets)
		
		let removed = previouslySelected.subtracting(newlySelected)
		let new = newlySelected.subtracting(previouslySelected)
		
		preferredRulesetIds = preferredRulesetIds.subtracting(removed.identifiers).union(new.identifiers)

		// Update the active rulesets with the selected rulesets
		activeRulesets = rulesets
	}
}

extension UserDefaults {
	
	private static let rulesetPreferencesKey = "preferredRulesetIds"
	
	func store(_ preferredRulesetIds: Set<AirMapRulesetId>) {
		let strings = preferredRulesetIds.map { $0.rawValue }
		setValue(strings, forKey: UserDefaults.rulesetPreferencesKey)
	}
	
	func preferredRulesetIds() -> Set<AirMapRulesetId> {
		let strings = stringArray(forKey: UserDefaults.rulesetPreferencesKey) ?? []
		let ids = strings.map { AirMapRulesetId(rawValue: $0)}
		return Set(ids)
	}
}
