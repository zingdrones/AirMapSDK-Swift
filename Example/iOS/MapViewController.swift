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
import RxSwift

class MapViewController: UIViewController {

	@IBOutlet weak var mapView: AirMapMapView!

	let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()

		AirMap.logger.minLevel = .Debug
		AirMap.authSessionDelegate = self
		AirMap.trafficDelegate = self
//		AirMap.configuration.distanceUnits = .Meters
//		AirMap.configuration.temperatureUnits = .Celcius
		
		mapView.configure(layers: [.EssentialAirspace, .TFRs], theme: .Standard)
	}
	
	@IBAction func addFlight() {

		if let flightPlanController = AirMap.flightPlanViewController(location: mapView.centerCoordinate, flightPlanDelegate: self, mapTheme: .Light, mapLayers: [.TFRs, .EssentialAirspace]) {
			presentViewController(flightPlanController, animated: true, completion: nil)
		} else {
			showAuthController()
		}
	}
	
	func showActiveFlight() {
		
		AirMap.rx_getCurrentAuthenticatedPilotFlight()
			.unwrap()
			.subscribeNext { [weak self] (flight) in
				let nav = AirMap.flightPlanViewController(flight)!
				self?.presentViewController(nav, animated: true, completion: nil)
			}
			.addDisposableTo(disposeBag)
	}

	private func showAuthController() {

		let authViewController = AirMap.authViewController(handleLogin)
//		authViewController.registerLogo("<YOUR_LOGO_CONNECT_WITH_AIRMAP>", bundle: NSBundle.mainBundle())
		
		presentViewController(authViewController, animated: true, completion: nil)
	}
	
	private func handleLogin(pilot: AirMapPilot?, error: NSError?) {
		
		guard let pilot = pilot where error == nil else {
			AirMap.logger.error(error)
			return
		}
		
		dismissViewControllerAnimated(true, completion: {
			
			if pilot.phoneVerified == false {
				let verification = AirMap.phoneVerificationViewController(pilot, phoneVerificationDelegate: self)
				self.presentViewController(verification, animated: true, completion: nil)
			} else {
				self.addFlight()
			}
		})
	}
}

extension MapViewController: AirMapPhoneVerificationDelegate {
	
	func phoneVerificationDidVerifyPhoneNumber() {
		dismissViewControllerAnimated(true, completion: nil)
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
		
		let coordinate = mapView.centerCoordinate
		try! AirMap.sendTelemetryData(flight, coordinate: coordinate, altitudeAgl: 100, altitudeMsl: nil)
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
	
	func mapView(mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
		

	}
	
	func mapView(mapView: MGLMapView, didSelectAnnotation annotation: MGLAnnotation) {
		if let flight = annotation as? AirMapFlight,
			flightNav = AirMap.flightPlanViewController(flight) {
			presentViewController(flightNav, animated: true, completion: nil)
		}
	}

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
