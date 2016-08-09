//
//  AirMapAircraft.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/15/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

@objc public class AirMapAircraft: NSObject {
	
	public var aircraftId: String!
	public var nickname: String!
	public var model: AirMapAircraftModel!
	
	public required init?(_ map: Map) {}
	public override init() { super.init() }
}

extension AirMapAircraft: Mappable {
	
	public func mapping(map: Map) {
		aircraftId  <-  map["id"]
		nickname    <-  map["nickname"]
		model       <-  map["model"]
	}
	
	/**
	Returns key value parameters
	
	- returns: [String: AnyObject]
	*/
	
	func params() -> [String: AnyObject] {
		
		var params = [String: AnyObject]()
		
		params["model_id"] = model?.modelId
		params["nickname"] = nickname
		
		return params
	}
}

func ==(lhs: AirMapAircraft, rhs: AirMapAircraft) -> Bool {
	return lhs.aircraftId == rhs.aircraftId
}
