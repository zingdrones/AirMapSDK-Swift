//
//  AirMapRule.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 4/7/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

/// A required action, condition, or input for the legal operation of a flight
public struct AirMapRule {
	
	/// A long-form textual description
	public let description: String
	
	/// A short-form textual description
	public let shortText: String?
	
	/// Flight features/input necessary to properly evaluate this rule
	public let flightFeatures: [AirMapFlightFeature]
	
	/// The order in which this rule should be displayed
	public let displayOrder: Int

	/// The evaluation status of this rule
	public let status: Status

	/// The evaluation status of a rule. Only evaluated when the rule is return as part of a flight briefing.
	///
	/// - conflicting: The flight plan properties or input provided conflicts with the rule
	/// - missingInfo: The flight plan properties or input is missing and the rule cannot be evaluated
	/// - informational: The status cannot be computationally evaluated but is provided for informational purposes
	/// - notConflicting: The rule has been evaluated as non-conflicting based on the flight plan properties or input provided
	/// - unevaluated: The rule has not yet been evaluated by the AirMap rules engine
	public enum Status: String {
		case conflicting
		case missingInfo = "missing_info"
		case informational
		case notConflicting = "not_conflicting"
		case unevaluated
	}
}
