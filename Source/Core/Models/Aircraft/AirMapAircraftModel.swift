//
//  AirMapDrone.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/15/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

public struct AirMapAircraftModel {
	
	public let id: String
	public let name: String
	public let manufacturer: AirMapAircraftManufacturer
	public let metadata: [String: AnyObject]?
}
