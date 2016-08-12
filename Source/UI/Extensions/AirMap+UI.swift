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

	- parameter location: The lat/lon origin of the flight
	- parameter flightPlanDelegate: The delegate that is notified of the new AirMapFlight after completion of flow

	- returns: An AirMapFlightPlanNavigationController if Pilot is Authenticated, otherwise nil.

	*/
	public class func flightPlanViewController(location location: CLLocationCoordinate2D, flightPlanDelegate: AirMapFlightPlanDelegate) -> AirMapFlightPlanNavigationController? {

		guard AirMap.authSession.hasValidCredentials() else { return nil }

		let storyboard = UIStoryboard(name: "AirMapUI", bundle: NSBundle(forClass: AirMap.self))

		let flightPlanNav = storyboard.instantiateInitialViewController() as! AirMapFlightPlanNavigationController
		flightPlanNav.flightPlanDelegate = flightPlanDelegate

		let flightVC = flightPlanNav.viewControllers.first as! AirMapFlightPlanViewController
		flightVC.location = Variable(location)

		return flightPlanNav
	}

	/**
	Creates an aircraft manufacturer and model selection view controller

	- parameter aircraftSelectionDelegate: The delegate to be notified of the selected AirMapAircraftModel on completion

	- returns: An AirMapAircraftModelNavController if Pilot is Authenticated, otherwise nil.

	*/
	public class func aircraftModelViewController(aircraftSelectionDelegate: AirMapAircraftModelSelectionDelegate) -> AirMapAircraftModelNavController? {

		guard AirMap.authSession.hasValidCredentials() else {
			return nil
		}

		let storyboard = UIStoryboard(name: "AirMapUI", bundle: NSBundle(forClass: AirMap.self))

		let aircraftNav = storyboard.instantiateViewControllerWithIdentifier(String(AirMapAircraftModelNavController)) as! AirMapAircraftModelNavController
		aircraftNav.aircraftModelSelectionDelegate = aircraftSelectionDelegate

		return aircraftNav
	}

	/**
	Creates an AirMap authentication view controller

	- parameter airMapAuthDelegate: The delegate to be notified when authentication succeeds or fails

	*/
	public class func authViewController(airMapAuthSessionDelegate airMapAuthSessionDelegate: AirMapAuthSessionDelegate) -> AirMapAuthViewController {

		let storyboard = UIStoryboard(name: "AirMapUI", bundle: NSBundle(forClass: AirMap.self))

		let authController = storyboard.instantiateViewControllerWithIdentifier(String(AirMapAuthViewController)) as! AirMapAuthViewController
		authController.authSessionDelegate = airMapAuthSessionDelegate

		return authController
	}

}
