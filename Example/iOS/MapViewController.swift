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

	@IBOutlet weak var mapView: AirMapMapView!

	override func viewDidLoad() {
		super.viewDidLoad()

		AirMap.logger.minLevel = .Debug
		AirMap.authSessionDelegate = self
		AirMap.trafficDelegate = self

		mapView.configure(layers: [.EssentialAirspace, .TFRs], theme: .Light)
	}

	@IBAction func addFlight() {

		if let flightPlanController = AirMap.flightPlanViewController(location: mapView.centerCoordinate, flightPlanDelegate: self) {
			presentViewController(flightPlanController, animated: true, completion: nil)
		} else {
			openLoginForm()
		}
	}

	func openLoginForm() {
		let auth = AirMap.authViewController(airMapAuthSessionDelegate: self)
		presentViewController(auth, animated: true, completion: nil)
	}
}

extension MapViewController: AirMapAuthSessionDelegate {

	func airmapSessionShouldAuthenticate() {

	}

	func airMapAuthSessionDidAuthenticate(pilot: AirMapPilot) {
		dismissViewControllerAnimated(true, completion: addFlight)

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

	func airMapFlightPlanDidEncounter(error: NSError) {
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

extension MapViewController: MGLMapViewDelegate {

	func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
		
		switch annotation {
		
		case is AirMapFlight:
			let image = AirMapImage.flightIcon(.Active)!
			return MGLAnnotationImage(image: image, reuseIdentifier: "flightIcon")
		
		case is AirMapTraffic:

			let traffic = annotation as! AirMapTraffic
			let image = AirMapImage.trafficIcon(traffic.trafficType, heading: traffic.trueHeading)!
			return MGLAnnotationImage(image: image, reuseIdentifier: traffic.id)
		
		default:
			return nil
		}
	}

	func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
		return true
	}

}
