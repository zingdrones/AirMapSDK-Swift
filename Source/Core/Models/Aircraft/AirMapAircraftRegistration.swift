//
//  AirMapAircraftRegistration.swift
//  AirMapSDK
//
//  Created by Michael Odere on 12/1/19.
//
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

public class AirMapAircraftRegistration: ImmutableMappable {

	public var id: AirMapAircraftRegistrationId?
	public var authority: String
	public var number: String
	public var name: String
	public var aircraftId: AirMapAircraftId?

	public init(authority: String, number: String, name: String) {
		self.authority = authority
		self.number = number
		self.name = name
	}

	required public init(map: Map) throws {
		do {
			id          =  try? map.value("id")
			authority   =  try  map.value("registration_authority")
			number      =  try  map.value("registration_number")
			name        =  try  map.value("name")
			aircraftId  =  try  map.value("aircraft_id")
		}
		catch {
			AirMap.logger.error("Failed to parse AirMapAircraftRegistration", metadata: ["error": .string(error.localizedDescription)])
			throw error
		}
	}

	public func mapping(map: Map) {
		number       >>>   map["registration_number"]
		authority    >>>   map["registration_authority"]
		name         >>>   map["name"]
	}
}
