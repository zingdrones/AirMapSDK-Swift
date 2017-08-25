//
//  Result.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/25/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation

/// An wrapper enum that encapsulates all responses from the AirMapSDK returning only one of two cases: value or error
///
/// - value: The requested value
/// - error: An error describing the failure
public enum Result<T> {
	case value(T)
	case error(AirMapError)
}
