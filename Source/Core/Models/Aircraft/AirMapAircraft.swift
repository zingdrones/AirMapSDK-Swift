//
//  AirMapAircraft.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/15/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

final public class AirMapAircraft: Codable {
	
	public var nickname: String?
	public let model: AirMapAircraftModel
	public let id: AirMapAircraftId?
	
	public init(model: AirMapAircraftModel, nickname: String) {
		self.model = model
		self.nickname = nickname
		self.id = nil
	}
	
}
