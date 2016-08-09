//
//  AirMap+UI.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/18/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift

private typealias AirMap_UI = AirMap
extension AirMap_UI {

	/**
	Creates a flight plan creation view controller that can be presented to the user based on a specified location. Airspace status, advisories, permiting, and digital notice are handled within the flow.

	- parameter flight: Existing flight plan to update
	- parameter location: The lat/lon origin of the flight
	- parameter flightPlanDelegate: The delegate that is notified of the new AirMapFlight after completion of flow

	*/
	public class func flightPlanViewController(flight: AirMapFlight?, location: CLLocationCoordinate2D, flightPlanDelegate: AirMapFlightPlanDelegate) -> AirMapFlightPlanNavigationController {

		let storyboard = UIStoryboard(name: "AirMapUI", bundle: NSBundle(forClass: AirMap.self))

		let flightPlanNav = storyboard.instantiateInitialViewController() as! AirMapFlightPlanNavigationController
		flightPlanNav.flightPlanDelegate = flightPlanDelegate

		if let flight = flight { flightPlanNav.flight.value = flight }

		let flightVC = flightPlanNav.viewControllers.first as! AirMapFlightPlanViewController
		flightVC.location = Variable(location)

		return flightPlanNav
	}

	/**
	Creates an aircraft manufacturer and model selection view controller

	- parameter aircraftSelectionDelegate: The delegate to be notified of the selected AirMapAircraftModel on completion

	*/
	public class func aircraftModelViewController(aircraftSelectionDelegate: AirMapAircraftModelSelectionDelegate) -> AirMapAircraftModelNavController {

		let storyboard = UIStoryboard(name: "AirMapUI", bundle: NSBundle(forClass: AirMap.self))

		let aircraftNav = storyboard.instantiateViewControllerWithIdentifier(String(AirMapAircraftModelNavController)) as! AirMapAircraftModelNavController
		aircraftNav.aircraftModelSelectionDelegate = aircraftSelectionDelegate

		return aircraftNav
	}

	/**
	Creates an AirMap authentication view controller

	- parameter airMapAuthDelegate: The delegate to be notified when authentication succeeds or fails

	*/
	public class func authViewController(airMapAuthSessionDelegate airMapAuthSessionDelegate: AirMapAuthSessionDelegate, completionHandler: ((token: String) -> Void)? = nil) -> AirMapAuthViewController {

		let storyboard = UIStoryboard(name: "AirMapUI", bundle: NSBundle(forClass: AirMap.self))

		let authController = storyboard.instantiateViewControllerWithIdentifier(String(AirMapAuthViewController)) as! AirMapAuthViewController
		authController.authSessionDelegate = airMapAuthSessionDelegate

		return authController
	}



}
