//
//  Int+AirMap.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/2/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

extension Int {
	func secondsToHoursMinutesSeconds() -> (hours: Int, minutes: Int, seconds: Int) {
		return (self / 3600, (self % 3600) / 60, (self % 3600) % 60)
	}
}

extension TimeInterval {
	
	func secondsToHoursMinutesSeconds() -> (hours: TimeInterval, minutes: TimeInterval, seconds: TimeInterval) {
		
		let hours = floor(self / 3600)
		let minutes = truncatingRemainder(dividingBy: 3600) / 60
		let seconds = truncatingRemainder(dividingBy: 3600).truncatingRemainder(dividingBy: 60)
		
		return (hours, minutes, seconds)
	}
}
