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
	
	private let mapLayers: [AirMapLayerType] = [.essentialAirspace, .tfrs]
	private let mapTheme: AirMapMapTheme = .standard
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		AirMap.logger.minLevel = .debug
		AirMap.authSessionDelegate = self
		AirMap.trafficDelegate = self
		AirMap.configuration.distanceUnits = .imperial // or .metric
		AirMap.configuration.temperatureUnits = .fahrenheit // or .celcius
		
		mapView.configure(layers: mapLayers, theme: mapTheme)
	}
	
	@IBAction func addFlight() {
		
		if let flightPlanController = AirMap.flightPlanViewController(location: mapView.centerCoordinate, flightPlanDelegate: self, mapTheme: mapTheme, mapLayers: mapLayers) {
			present(flightPlanController, animated: true, completion: nil)
		} else {
			showAuthController()
		}
	}
	
	func showActiveFlight() {
		
		AirMap.getCurrentAuthenticatedPilotFlight { result in
			switch result {
			case .error(let error):
				AirMap.logger.error(error)
			case .value(let flight):
				if let flight = flight {
					let nav = AirMap.flightPlanViewController(flight)!
					self.present(nav, animated: true, completion: nil)
				}
			}
		}
	}
	
	fileprivate func showAuthController() {
		
		let authViewController = AirMap.authViewController(handleLogin)
		//		authViewController.registerLogo("<YOUR_LOGO_CONNECT_WITH_AIRMAP>", bundle: NSBundle.mainBundle())
		
		present(authViewController, animated: true, completion: nil)
	}
	
	fileprivate func handleLogin(result: Result<AirMapPilot>) {
		
		switch result {
		case .error(let error):
			AirMap.logger.error(error)
		case .value(let pilot):
			dismiss(animated: true, completion: {
				if pilot.phoneVerified == false {
					let verification = AirMap.phoneVerificationViewController(pilot, phoneVerificationDelegate: self)
					self.present(verification, animated: true, completion: nil)
				} else {
					self.addFlight()
				}
			})
		}
	}
}

extension MapViewController: AirMapPhoneVerificationDelegate {
	
	func phoneVerificationDidVerifyPhoneNumber() {
		dismiss(animated: true, completion: nil)
	}
}

extension MapViewController: AirMapAuthSessionDelegate {
	
	func airmapSessionShouldAuthenticate() {
		
	}
	
	func airMapAuthSessionDidAuthenticate(_ pilot: AirMapPilot) {
		if presentedViewController?.childViewControllers.first is AirMapAuthViewController {
			dismiss(animated: true, completion: addFlight)
		}
	}
	
	func airMapAuthSessionAuthenticationDidFail(_ error: Error) {
		AirMap.logger.error(error)
	}
}

extension MapViewController: AirMapFlightPlanDelegate {
	
	func airMapFlightPlanDidEncounter(_ error: Error) {
		AirMap.logger.error(error)
	}
	
	func airMapFlightPlanDidCreate(_ flight: AirMapFlight) {
		mapView.addAnnotation(flight)
		if presentedViewController is AirMapFlightPlanNavigationController {
			dismiss(animated: true, completion: nil)
		}
		let coordinate = mapView.centerCoordinate
		try! AirMap.sendTelemetryData(flight, coordinate: coordinate, altitudeAgl: 100, altitudeMsl: nil)
	}
	
}

extension AirMapTraffic: MGLAnnotation {
	
	public var title: String? {
		return properties.aircraftId
	}
}

extension MapViewController: AirMapTrafficObserver {
	
	func airMapTrafficServiceDidAdd(_ traffic: [AirMapTraffic]) {
		mapView.addAnnotations(traffic)
	}
	
	func airMapTrafficServiceDidUpdate(_ traffic: [AirMapTraffic]) {
		// annotations are updated via KVO
	}
	
	func airMapTrafficServiceDidRemove(_ traffic: [AirMapTraffic]) {
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
	
	func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
		
	}
	
	func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
		if let flight = annotation as? AirMapFlight,
			let flightNav = AirMap.flightPlanViewController(flight) {
			present(flightNav, animated: true, completion: nil)
		}
	}
	
	func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
		
		switch annotation {
			
		case is AirMapFlight:
			let flightIcon = AirMapImage.flightIcon(.active)!
			return MGLAnnotationImage(image: flightIcon, reuseIdentifier: "flightIcon")
			
		case let traffic as AirMapTraffic:
			let trafficIcon = AirMapImage.trafficIcon(type: traffic.trafficType, heading: traffic.trueHeading)!
			return MGLAnnotationImage(image: trafficIcon, reuseIdentifier: traffic.id)
			
		default:
			return nil
		}
	}
	
	func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
		return true
	}
	
}
