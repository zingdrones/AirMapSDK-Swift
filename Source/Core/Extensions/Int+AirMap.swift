//
//  Int+AirMap.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/2/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

extension Int {
	func secondsToHoursMinutesSeconds () -> (Int, Int, Int) {
		return (self / 3600, (self % 3600) / 60, (self % 3600) % 60)
	}
}
