//
//  AirMapRule.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 4/7/17.
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

/// A required action, condition, or input for the legal operation of a flight
public struct AirMapRule {
	
	/// A long-form textual description
	public let description: String?
	
	/// A short-form textual description
	public let shortText: String
	
	/// Flight features/input necessary to properly evaluate this rule
	public let flightFeatures: [AirMapFlightFeature]
	
	/// The order in which this rule should be displayed
	public let displayOrder: Int

	/// The collective evaluation status of this rule's flight features
	public let status: AirMapFlightFeature.Status
}
