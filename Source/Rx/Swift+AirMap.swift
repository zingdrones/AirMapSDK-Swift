//
//  Swift+AirMap.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/14/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

/// Convenience method for wrapping closure parameters with `[unowned self]` to prevent retain cycles
func unowned<Type: AnyObject, Parameters, ReturnValue>
	(_ instance: Type, _ function: @escaping ((Type) -> (Parameters) -> ReturnValue)) -> ((Parameters) -> ReturnValue) {
	
	return { [unowned instance] parameters -> ReturnValue in
		return function(instance)(parameters)
	}
}
