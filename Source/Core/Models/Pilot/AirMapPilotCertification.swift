//
//  AirMapPilotCertification.swift
//  AirMapSDK
//
//  Created by Michael Odere on 12/3/19.
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

public class AirMapPilotCertification: ImmutableMappable {

	public let id: AirMapPilotCertificationId?
	public let certificationAuthority: String
	public let certificationId: String

	required public init(map: Map) throws {
		do {
			id                      =  try? map.value("id")
			certificationAuthority  =  try  map.value("certification_authority")
			certificationId         =  try  map.value("certification_id")
		}
		catch {
			AirMap.logger.error("Failed to parse AirMapPilotCertification", metadata: ["error": .string(error.localizedDescription)])
			throw error
		}
	}

	public func mapping(map: Map) {
		certificationAuthority   >>>   map["certification_authority"]
		certificationId          >>>   map["certification_id"]
	}
}
