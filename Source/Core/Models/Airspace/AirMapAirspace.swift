//
//  AirMap+Airspace.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/29/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

internal struct AirMapAirspace {
	
	let id: String
	let name: String
	let type: AirMapAirspaceType
	let country: String
	let state: String?
	let city: String?
	let geometry: AirMapGeometry
	let propertyBoundary: AirMapGeometry?
}
