//
//  Color+App.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/19/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//


#if os(OSX)
	import AppKit
	public typealias ColorType = NSColor
#else
	import UIKit
	public typealias ColorType = UIColor
#endif

extension ColorType {

	class func airMapLightBlue() -> ColorType {
		return ColorType(red: 136.0/255.0, green: 219.0/255.0, blue: 223.0/255.0, alpha: 1.0)
	}

	class func airMapDarkBlue() -> ColorType {
		return ColorType(red: 52.0/255.0, green: 64.0/255.0, blue: 82.0/255.0, alpha: 1.0)
	}
	
	class func airMapGray() -> ColorType {
		return ColorType(red: 51.0/255.0, green: 63.0/255.0, blue: 72.0/255.0, alpha: 1.0)
	}
	
	class func airMapGreen() -> ColorType {
		return ColorType(red: 108.0/255.0, green: 194.0/255.0, blue: 74.0/255.0, alpha: 1.0)
	}
	
	class func airMapYellow() -> ColorType {
		return ColorType(red: 248.0/255.0, green: 231.0/255.0, blue: 28.0/255.0, alpha: 1.0)
	}
	
	class func airMapRed() -> ColorType {
		return ColorType(red: 255.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
	}
	
	class func airMapBlack() -> ColorType {
		return .blackColor()
	}

}
