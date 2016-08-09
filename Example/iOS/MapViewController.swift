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

class MapViewController: UIViewController {

	@IBOutlet weak var mapView: MGLMapView!

	override func viewDidLoad() {
		super.viewDidLoad()

		AirMap.configure(apiKey: <#AirMap API Key#>)
		AirMap.trafficDelegate = self
		MGLAccountManager.setAccessToken(<#Mapbox API Key#>)
	}

	@IBAction func addFlight() {

		if AirMap.authToken != nil {
			return openFlightCreationForm()
		}

		let auth = AirMap.authViewController(airMapAuthSessionDelegate: self)
		presentViewController(auth, animated: true, completion: nil)

	}

	func openFlightCreationForm() {
		let flightPlanNav = AirMap.flightPlanViewController(nil, location: mapView.centerCoordinate, flightPlanDelegate: self)
		presentViewController(flightPlanNav, animated: true, completion: nil)
	}
}

extension MapViewController: AirMapAuthSessionDelegate {

	func airmapSessionShouldReauthenticate(handler: ((token: String) -> Void)?) {

	}

	func airMapAuthSessionDidAuthenticate(pilot: AirMapPilot) {
		dismissViewControllerAnimated(true, completion: { self.openFlightCreationForm() })

	}
	func airMapAuthSessionAuthenticationDidFail(error: NSError) {
		print(error.localizedDescription)
	}
}

extension MapViewController: AirMapFlightPlanDelegate {
	
	func airMapFlightPlanDidCreate(flight: AirMapFlight) {
		mapView.addAnnotation(flight)
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	func airMapFlightPlanDidEncounter(error: ErrorType) {
		print(error)
	}

}


extension AirMapTraffic: MGLAnnotation {

	public var title: String? {
		return properties.aircraftId
	}

}

extension MapViewController: AirMapTrafficObserver {

	func airMapTrafficServiceDidAdd(traffic: [AirMapTraffic]) {
		mapView.addAnnotations(traffic)
	}

	func airMapTrafficServiceDidUpdate(traffic: [AirMapTraffic]) {
		// annotations are updated via KVO
	}

	func airMapTrafficServiceDidRemove(traffic: [AirMapTraffic]) {
		mapView.removeAnnotations(traffic)
	}

	func airMapTrafficServiceDidConnect() {
		print("Connected")
	}

	func airMapTrafficServiceDidDisconnect() {
		print("Disconnected")
	}

}
