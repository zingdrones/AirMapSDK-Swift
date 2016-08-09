//
//  Airmap+Log.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/28/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Log

extension AirMap {
	
	public static let logger = Logger(formatter: Formatter("AirMapSDK %@: %@", .Level, .Message), minLevel:  .Debug)
	
}
