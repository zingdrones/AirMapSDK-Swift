//
//  AirMapAircraft.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/15/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

open class AirMapAircraft {
	
	open var aircraftId: String!
	open var nickname: String!
	open var model: AirMapAircraftModel!
	
	public required init?(map: Map) {}
	public init() { }
}

extension AirMapAircraft: Mappable {
	
	public func mapping(map: Map) {
		aircraftId  <-  map["id"]
		nickname    <-  map["nickname"]
		model       <-  map["model"]
	}
	
	internal func params() -> [String: Any] {
		
		return [
			"model_id": model?.modelId as Any,
			"nickname": nickname
		]
	}
}

extension AirMapAircraft: Equatable, Hashable {
	
	public static func ==(lhs: AirMapAircraft, rhs: AirMapAircraft) -> Bool {
		return lhs.aircraftId == rhs.aircraftId
	}

	public var hashValue: Int {
		return aircraftId.hashValue
	}
}
