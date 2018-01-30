//
//  AirMap.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 5/26/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

/// The `AirMap` class encapsulates all platform interactions for Rules, Advisories, Flight, Pilot, and more.
public class AirMap {

	/// The current environment settings and configuration of the AirMap SDK. Must be explicity set or loaded from an airmap.config.json file.
	public static var configuration: AirMapConfiguration {
		get { return AirMapConfiguration.custom ?? .json }
		set { AirMapConfiguration.custom = newValue }
	}
	
	private init() {}
}
