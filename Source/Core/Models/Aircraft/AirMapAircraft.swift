//
//  AirMapAircraft.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/15/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

final public class AirMapAircraft {
	
	public internal(set) var model: AirMapAircraftModel
	public var nickname: String?
	public internal(set) var id: String?
	
	public init(model: AirMapAircraftModel, nickname: String) {
		self.model = model
		self.nickname = nickname
	}
}
import ObjectMapper

extension AirMapAircraft: ImmutableMappable {
	
	public convenience init(map: Map) throws {
		let model: AirMapAircraftModel     =  try  map.value("model")
		
		AirMapAircraft(model: model, nickname: "")
		
		self.id        =  try? map.value("id")
		self.nickname  =  try? map.value("nickname")
	}
}
