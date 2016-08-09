//
//  AirMapApiData.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/20/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapGeometry: NSObject {

	required public init?(_ map: Map) {}

	public override init() {
		super.init()
	}

	public func params() -> [String: AnyObject] {
		let params = [String: AnyObject]()
		return params
	}
	
}
