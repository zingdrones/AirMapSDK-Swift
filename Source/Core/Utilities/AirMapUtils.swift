//
//  AirMapUtils.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/10/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

public class AirMapBundle {

	/**
	Returns the AirMap SDK Bundle
	*/

	public class func mainBundle() -> NSBundle {
		return NSBundle(forClass: AirMap.self)
	}
}
