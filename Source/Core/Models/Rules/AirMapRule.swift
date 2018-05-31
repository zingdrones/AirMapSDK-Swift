//
//  AirMapRule.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 4/7/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

/// A required action, condition, or input for the legal operation of a flight
public struct AirMapRule: Codable {

	/// A long-form textual description
	public let description: String?
	
	/// A short-form textual description
	public let shortText: String
	
	/// Flight features/input necessary to properly evaluate this rule
	public let flightFeatures: [AirMapFlightFeature]
	
	/// The order in which this rule should be displayed
	public let displayOrder: Int

	/// The collective evaluation status of this rule's flight features
	public let status: AirMapFlightFeature.Status?
}
