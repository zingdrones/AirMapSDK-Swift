//
//  AirMapFlightFeature.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 4/8/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapFlightFeature: Mappable {
		
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
	
	public let id: Int
	public let feature: String
	public let description: String
	public let inputType: InputType
	
	public required init?(map: Map) {

		do {
			id          = try map.value("id")
			feature     = try map.value("flight_feature")
			description = try map.value("description")
			inputType   = try map.value("input_type")
		}
		
		catch let error {
			print(error)
			return nil
		}
	}
	
	public func mapping(map: Map) {}
}

extension AirMapFlightFeature: Equatable, Hashable {
	
	static public func ==(lhs: AirMapFlightFeature, rhs: AirMapFlightFeature) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}

	public var hashValue: Int {
		return id.hashValue
	}
}

