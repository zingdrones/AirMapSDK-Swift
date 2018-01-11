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
	public internal(set) var model: AirMapAircraftModel
	public internal(set) var id: AirMapAircraftId?
	
	public init(model: AirMapAircraftModel, nickname: String) {
		self.model = model
		self.nickname = nickname
		self.id = nil
	}
}
