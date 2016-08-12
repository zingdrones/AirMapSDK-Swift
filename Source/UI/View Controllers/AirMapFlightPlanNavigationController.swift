//
//  AirMapFlightPlanNavigationController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/18/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift

public protocol AirMapFlightPlanDelegate {
	
	func airMapFlightPlanDidCreate(flight: AirMapFlight)
	func airMapFlightPlanDidEncounter(error: NSError)
}

public class AirMapFlightPlanNavigationController: UINavigationController {

	var flightPlanDelegate: AirMapFlightPlanDelegate!

	let flight = Variable(AirMapFlight())
	let status = Variable(nil as AirMapStatus?)
	let submitDigitalNotice = Variable(true)
	let shareFlight = Variable(true)

	let requiredPermits = Variable([AirMapAvailablePermit]())

	let draftPermits    = Variable([AirMapPilotPermit]())
	let existingPermits = Variable([AirMapPilotPermit]())

	let selectedPermits = Variable([(advisory: AirMapStatusAdvisory, permit: AirMapAvailablePermit, pilotPermit: AirMapPilotPermit)]())

	public override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}

	@IBAction func unwindToFlightPlan(segue: UIStoryboardSegue) { /* unwind segue hook; keep */ }

}
