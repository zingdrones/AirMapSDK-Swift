//
//  AirMapAircraftModelNavController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/27/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit

public protocol AirMapAircraftModelSelectionDelegate: class {
	
	func didSelectAircraftModel(_ model: AirMapAircraftModel?)
}

open class AirMapAircraftModelNavController: UINavigationController {
	
	open weak var aircraftModelSelectionDelegate: AirMapAircraftModelSelectionDelegate?
}
