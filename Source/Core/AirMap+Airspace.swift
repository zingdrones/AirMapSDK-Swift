//
//  AirMap+Airspace.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/29/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
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
	internal static func getAirspace(_ airspaceId: String, completion: @escaping (Result<AirMapAirspace>) -> Void) {
		airspaceClient.getAirspace(airspaceId).thenSubscribe(completion)
	}

}
