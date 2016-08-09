//
//  AirMapAircraftModelNavController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/27/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

public protocol AirMapAircraftModelSelectionDelegate {
	
	func didSelectAircraftModel(model: AirMapAircraftModel?)
}

public class AirMapAircraftModelNavController: UINavigationController {
	
	public var aircraftModelSelectionDelegate: AirMapAircraftModelSelectionDelegate?
}
