//
//  AirMapLocationUtils.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/2/16.
/*
Copyright 2018 AirMap, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
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
