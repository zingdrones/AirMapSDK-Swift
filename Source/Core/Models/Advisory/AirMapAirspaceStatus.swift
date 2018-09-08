//
//  AirMapAirspaceStatus.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 4/10/17.
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

public struct AirMapAirspaceStatus {

	/// A color representative of the action level of the advisory
	public let color: AirMapAdvisory.Color
	
	/// A collection of airspace advisories relevant to the area of operation
	public let advisories: [AirMapAdvisory]
}

// MARK: - Convenience

extension AirMapAirspaceStatus {
	
	/// A flag that indicates that digitial notification is supported in the area
	public var supportsDigitalNotification: Bool {
		return advisories.first(where: { $0.requirements?.notice?.digital == true }) != nil
	}
}
