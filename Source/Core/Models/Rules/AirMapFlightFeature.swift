//
//  AirMapFlightFeature.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 4/8/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapFlightFeature: Mappable {
	
	public enum InputType {
		case bool(Bool)
		case float(Double)
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
	
//	func objectForMapping(map: Map) -> BaseMappable? {
//		
//		guard let type: String = map["input_type"].value() else { return nil }
//	
//		switch type {
//		case "bool":
//			return AirMapFlightFeature<Bool>.self
//		case "float":
//			return AirMapFlightFeature<Double>.self
//		default:
//			return nil
//		}
//	}
}

extension AirMapFlightFeature: Equatable, Hashable {
	
	static public func ==(lhs: AirMapFlightFeature, rhs: AirMapFlightFeature) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}

	public var hashValue: Int {
		return id.hashValue
	}
}

