//
//  AirMap+Airspace.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/29/16.
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

extension AirMap {
	
	// MARK: - Airspace

	/// Get detailed information about an airspace object.
	///
	/// - Important: Access to this API is restricted. Contact Support for access.
	///
	/// - Parameters:
	///   - airspaceId: The unique identifier associated with the airspace object
	///   - completion: A completion handler to call with the Result
	internal static func getAirspace(_ airspaceId: AirMapAirspaceId, completion: @escaping (Result<AirMapAirspace>) -> Void) {
		rx.getAirspace(airspaceId).thenSubscribe(completion)
	}

}
