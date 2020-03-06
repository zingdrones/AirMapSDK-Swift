//
//  AirMapFlightFeature.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 4/8/17.
//  Copyright 2018 AirMap, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

/// A representation of the context or input required to properly brief a flight plan.
public struct AirMapFlightFeature {
	
	/// The unique identifier for the flight feature
	public let id: AirMapFlightFeatureId
	
	/// A textual description of the flight feature
	public let description: String
	
	/// The type of input the flight feature requires
	public let inputType: InputType?
	
	/// The measurement type of the input
	public let measurementType: MeasurementType
	
	/// The unit to use for the measurement type
	public let measurementUnit: MeasurementUnit?
	
	// The evaluation status of the flight feature
	public let status: Status
	
	// The flight feature is calculated, no input needed
	public let isCalculated: Bool
	
	/// The evaluation status of a flight feature.
	///
	/// - conflicting: The flight plan properties or input provided conflicts with a rule
	/// - missingInfo: The flight plan properties or input is missing and therefore cannot be evaluated
	/// - informational: The status cannot be computationally evaluated but is provided for informational purposes
	/// - notConflicting: The feature has been evaluated as non-conflicting based on the flight plan properties or input provided
	/// - unevaluated: The feature has not yet been evaluated by the AirMap rules engine
	public enum Status: String, CaseIterable {
		case conflicting
		case missingInfo = "missing_info"
		case informational
		case notConflicting = "not_conflicting"
		case unevaluated
	}

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
