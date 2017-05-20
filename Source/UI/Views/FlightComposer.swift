//
//  FlightComposer.swift
//  AirMap
//
//  Created by Adolfo Martinelli on 5/18/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import UIKit
import RxSwift

// MARK: - Public

public protocol AirMapFlightComposer: class, ControlPointDelegate {
	var mapView: AirMapMapView { get }
	func didStartComposing()
	func didFinishComposing(flightPlan: AirMapFlight?)
	func displayTooltip(message: String, level: TooltipType)
}

extension AirMapFlightComposer {
	
	public func startComposing() {
		guard mapView.flightComposeState == nil else {
			AirMap.logger.error("Flight compose already in progress. Call finishComposing() first")
			return
		}
		let draftFlightPlan = AirMapFlight()
		mapView.flightComposeState = FlightComposeState(flight: draftFlightPlan)
		configure(mode: .drawing)
		didStartComposing()
	}
	
	public func finishComposing() {
		let flight = mapView.flightComposeState?.flight
		didFinishComposing(flightPlan: flight)
		configure(mode: .finished)
		mapView.flightComposeState = nil
	}
}

public enum ComposeFlightType {
	case point
	case path
	case area
}

public enum TooltipType {
	case informational
	case warning
	case error
}

// MARK: - Internal

enum InteractionState {
	case panning
	case drawing
	case editing(ControlPoint)
	case finished
}

class FlightComposeState {
	let flight: AirMapFlight
	let state = Variable(InteractionState.panning)
	let selectedGeoType = Variable(AirMapFlight.FlightGeometryType.point)
	let controlPoints = Variable([ControlPoint]())
	let buffer = Variable(Feet(1000).meters)
	let controlPointsHidden = Variable(false)
	let disposeBag = DisposeBag()
	
	init(flight: AirMapFlight) {
		self.flight = flight
	}
}

extension AirMapFlightComposer {
	
	fileprivate func configure(mode: InteractionState) {
		switch mode {
		case .panning:
			break
		case .drawing:
			break
		case .editing(let point):
			print(point)
		case .finished:
			break
		}
	}
}

extension InteractionState: Equatable {
	
	static func ==(lhs: InteractionState, rhs: InteractionState) -> Bool {
		switch (lhs, rhs) {
		case (.panning, .panning), (.drawing, .drawing), (.finished, .finished):
			return true
		case (.editing(let point1), .editing(let point2)):
			return point1 === point2
		default:
			return false
		}
	}

}

