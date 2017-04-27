//
//  AirMapAircraft.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/15/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

final public class AirMapAircraft: Mappable {
	
	public private(set) var id: String!
	public private(set) var model: AirMapAircraftModel
	public var nickname: String

	@available(*, renamed: "id")
	public var aircraftId: String! {
		return id
	}
	
	public required init?(map: Map) {
		
		do {
			id        = try map.value("id")
			model     = try map.value("model")
			nickname  = try map.value("nickname")
		}
		catch let error {
			AirMap.logger.error(error)
			return nil
		}
	}
	
	@available (*, unavailable, renamed: "init(model:nickname:)")
	public init() { fatalError() }
	
	public init(model: AirMapAircraftModel, nickname: String) {
		self.model = model
		self.nickname = nickname
	}
	
	public func mapping(map: Map) {
		
		id         <-  map["id"]
		model      <-  map["model"]
		nickname   <-  map["nickname"]
	}
	
	internal func params() -> [String: Any] {
		
		return [
			"model_id": model.modelId,
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
