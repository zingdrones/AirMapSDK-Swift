//
//  AirMapFlightFeature.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 4/8/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

/// A representation of the context or input required to properly brief a flight plan.
public struct AirMapFlightFeature {
	
	/// The unique identifier for the flight feature
	public let id: String
	
	/// A textual description of the flight feature
	public let description: String
	
	/// The type of input the flight feature requires
	public let inputType: InputType
	
	/// The measurement type of the input
	public let measurementType: MeasurementType
	
	/// The unit to use for the measurement type
	public let measurementUnit: MeasurementUnit?

	/// The flight feature's concrete Type
	public enum InputType: String {
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
	public enum MeasurementType: String {
		case speed
		case weight
		case distance
		case binary
	}
	
	/// An enumeration of possible measurement units
	public enum MeasurementUnit: String {
		case meters
		case kilograms
		case boolean
		case metersPerSecond = "meters_per_sec"
	}
}
