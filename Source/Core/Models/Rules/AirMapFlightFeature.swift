//
//  AirMapFlightFeature.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 4/8/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class AirMapFlightFeature: Mappable {
	
	public let code: String
	public let description: String
	public let inputType: InputType
	public let measurementType: MeasurementType
	public let measurementUnit: MeasurementUnit

	public enum InputType: String {
		case bool
		case float

		var type: Any.Type {
			switch self {
			case .bool:  return Bool.self
			case .float: return Double.self
			}
		}
	}
	
	public enum MeasurementType: String {
		case weight
		case distance
		case binary
	}
	
	public enum MeasurementUnit: String {
		case meters
		case kilograms
		case boolean
	}
	
	public required init?(map: Map) {

		do {
			code            =  try  map.value("flight_feature")
			description     =  try  map.value("description")
			inputType       =  try  map.value("input_type")
			measurementType = (try? map.value("measurement_type")) ?? .binary
			measurementUnit = (try? map.value("measurement_unit")) ?? .boolean
		}
		
		catch let error {
			print(error)
			return nil
		}
	}
	
	public func mapping(map: Map) {}
	
}
