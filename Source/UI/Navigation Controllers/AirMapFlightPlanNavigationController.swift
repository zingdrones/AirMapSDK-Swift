//
//  AirMapFlightPlanNavigationController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/18/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift

public protocol AirMapFlightPlanDelegate: class {

	func airMapFlightPlanDidCreate(_ flight: AirMapFlight)
	func airMapFlightPlanDidEncounter(_ error: Error)
}

open class AirMapFlightPlanNavigationController: UINavigationController {

	weak var flightPlanDelegate: AirMapFlightPlanDelegate!
	
	var mapTheme: AirMapMapTheme = .standard
	var mapLayers: [AirMapLayerType] = []

	let flight = Variable(AirMapFlight())
	let status = Variable(nil as AirMapStatus?)
	let shareFlight = Variable(true)

	let draftPermits    = Variable([AirMapPilotPermit]())
	let existingPermits = Variable([AirMapPilotPermit]())
	let selectedPermits = Variable([(organization: AirMapOrganization, permit: AirMapAvailablePermit, pilotPermit: AirMapPilotPermit)]())
	
	open override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationBar.setBackgroundImage(UIImage(), for: .default)
		navigationBar.shadowImage = UIImage()
	}

	open override var preferredStatusBarStyle : UIStatusBarStyle {
		return .lightContent
	}

	@IBAction func unwindToFlightPlan(_ segue: UIStoryboardSegue) { /* unwind segue hook; keep */ }

}
