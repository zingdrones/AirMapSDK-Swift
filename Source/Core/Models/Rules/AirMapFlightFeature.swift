//
//  AirMapFlightFeature.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 4/8/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

/// A representation of the context or input required to properly brief a flight plan.
public struct AirMapFlightFeature: Codable {
	
	/// The unique identifier for the flight feature
	public let id: AirMapFlightFeatureId
	
	/// A textual description of the flight feature
	public let description: String
	
	/// The type of input the flight feature requires
	public let inputType: InputType?
	
	/// The measurement type of the input
	public let measurementType: MeasurementType?
	
	/// The unit to use for the measurement type
	public let measurementUnit: MeasurementUnit?
	
	// The evaluation status of the flight feature
	public let status: Status?
	
	// The flight feature is calculated, no input needed
	public let isCalculated: Bool
	
	/// The evaluation status of a flight feature.
	///
	/// - conflicting: The flight plan properties or input provided conflicts with a rule
	/// - missingInfo: The flight plan properties or input is missing and therefore cannot be evaluated
	/// - informational: The status cannot be computationally evaluated but is provided for informational purposes
	/// - notConflicting: The feature has been evaluated as non-conflicting based on the flight plan properties or input provided
	/// - unevaluated: The feature has not yet been evaluated by the AirMap rules engine
	public enum Status: String, Codable {
		case conflicting
		case missingInfo = "missing_info"
		case informational
		case notConflicting = "not_conflicting"
		case unevaluated
	}

	/// The flight feature's concrete Type
	public enum InputType: String, Codable {
		case bool
		case float
		case string

		var type: Any.Type {
			switch self {
			case .bool:  return Bool.self
			case .float: return Double.self
			case .string: return String.self
			}
		}
	}
	
	/// An enumeration of possible measurement types
	public enum MeasurementType: String, Codable {
		case speed
		case weight
		case distance
	}
	
	/// An enumeration of possible measurement units
	public enum MeasurementUnit: String, Codable {
		case meters
		case kilograms
		case metersPerSecond = "meters_per_sec"
	}
}
