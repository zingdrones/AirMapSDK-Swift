//
//  AirMapBundle.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/10/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

public class AirMapBundle {
	
	public class var core: Bundle {
		
		return bundleNamed("AirMapCore")
	}

	public class var ui: Bundle {
		
		return bundleNamed("AirMapUI")
	}
	
	private class func bundleNamed(_ name: String) -> Bundle {
		
		let frameworkBundle = Bundle(for: AirMap.self)
		let url = frameworkBundle.url(forResource: name, withExtension: "bundle")!
		let bundle = Bundle(url: url)!
		return bundle
	}
}
