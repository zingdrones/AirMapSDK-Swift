//
//  NSLocale+AirMap.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/10/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

class AirMapLocale: NSLocale {
	
	override class func currentLocale() -> NSLocale {
		
		// Workaround for bug in simulator
		#if (arch(i386) || arch(x86_64)) && os(iOS)
			let locale = NSLocale(localeIdentifier: "en_US")
		#else
			let locale = super.currentLocale()
		#endif
		
		return locale
	}

}
