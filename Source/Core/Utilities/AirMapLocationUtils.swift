//
//  AirMapLocationUtils.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/2/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

func convertDegreesToNearestCompassRose(_ degree: Int) -> Int {

	if degree > 0 && degree <= 45 {
		return 45
	}
	
	if degree > 45 && degree <= 90 {
		return 90
	}
	
	if degree > 90 && degree <= 135 {
		return 135
	}
	
	if degree > 125 && degree <= 180 {
		return 180
	}
	
	if degree > 180 && degree <= 225 {
		return 225
	}
	
	if degree > 225 && degree <= 270 {
		return 270
	}
	
	if degree > 270 && degree <= 360 {
		return 360
	}
	
	return 0
}
