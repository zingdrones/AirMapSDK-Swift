//
//  Date+AirMap.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 5/26/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

public extension Date {
	
	public func iso8601String() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
		dateFormatter.dateFormat = Constants.AirMapApi.dateFormat
		return dateFormatter.string(from: self)
	}
	
	func isInFuture() -> Bool {
		return self > Date()
	}
	
	func isInPast() -> Bool {
		return self < Date()
	}
}

extension TimeInterval {
	
	var milliseconds: UInt64 {
		return UInt64(self * 1000)
	}
}
