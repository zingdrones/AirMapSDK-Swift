//
//  Swift+AirMap.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/14/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//


/// Convenience method for wrapping closure parameters with `[unowned self]` to prevent retain cycles
func unowned<Type: AnyObject, Parameters, ReturnValue>
	(instance: Type, _ function: (Type -> Parameters -> ReturnValue)) -> (Parameters -> ReturnValue) {
	
	return { [unowned instance] parameters -> ReturnValue in
		return function(instance)(parameters)
	}
}
