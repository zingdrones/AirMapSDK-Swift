//
//  AirMapAircraft.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/15/16.
//  Copyright 2018 AirMap, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
	
	public init(map: Map) throws {
		id        =  try? map.value("id")
		nickname  =  try? map.value("nickname")
		model     =  try  map.value("model")
	}
}
