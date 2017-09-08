//
//  AirMapAircraft.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/15/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

final public class AirMapAircraft: ImmutableMappable {
	
	public var nickname: String?
	public private(set) var model: AirMapAircraftModel
	public private(set) var id: String?
	
	public init(model: AirMapAircraftModel, nickname: String) {
		self.model = model
		self.nickname = nickname
		self.id = nil
	}
	
	// MARK: - JSON Serialization

	public init(map: Map) throws {
		nickname  =  try? map.value("nickname")
		model     =  try  map.value("model")
		id        =  try? map.value("id")
	}
}
