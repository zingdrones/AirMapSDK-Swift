//
//  AirMapAdvisoryRequirements.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/13/16.
/*
Copyright 2018 AirMap, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
//

import Foundation

public struct AirMapAdvisoryRequirements {
	
	public let notice: Notice?
	
	public struct Notice {

		/// Notice may be provided digitally by AirMap to the controlling agency
		public let digital: Bool
		
		/// Manual notification may be provided via phone if `digital` is false
		public let phoneNumber: String?
	}
}
