//
//  AirMap.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 5/26/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

/// The principal AirMapSDK class that is extended for additional functionality for Rules, Advisories, Flight, Pilot, etc.
/// - SeeAlso: AirMap+Advisories
/// - SeeAlso: AirMap+Airspace
/// - SeeAlso: AirMap+Auth
/// - SeeAlso: AirMap+Flight
/// - SeeAlso: AirMap+FlightPlans
/// - SeeAlso: AirMap+Pilot
/// - SeeAlso: AirMap+Rules
public class AirMap {
	
	/// The current environment settings and configuration of the AirMap SDK. May be set explicity or will be loaded from a provided airmap.config.json file.
	public static var configuration: AirMapConfiguration = {
		return AirMapConfiguration.defaultConfig()
	}()
	
	private init() {}
}
