//
//  AirMapUIConstants.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/18/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

struct UIConstants {
	
	static let metersPerFoot: CLLocationDistance = 0.3048
	
	static let bufferPresets: [(title: String, value: CLLocationDistance)] = [
		("50 ft", metersPerFoot * 50),
		("100 ft", metersPerFoot * 100),
		("200 ft", metersPerFoot * 200),
		("300 ft", metersPerFoot * 300),
		("400 ft", metersPerFoot * 400),
		("500 ft", metersPerFoot * 500),
		("750 ft", metersPerFoot * 750),
		("1,000 ft", metersPerFoot * 1_000),
		("1,500 ft", metersPerFoot * 1_500),
		("2,000 ft", metersPerFoot * 2_000),
		("2,500 ft", metersPerFoot * 2_500),
		("3,000 ft", metersPerFoot * 3_000),
		]
	
	static let defaultBufferPreset = bufferPresets[7]

	static let altitudePresets: [(title: String, value: CLLocationDistance)] = [
		("50 ft", 15.24),
		("100 ft", 30.48),
		("200 ft", 60.96),
		("300 ft", 91.44),
		("400 ft", 121.92),
		("500 ft", 152.4),
		]
	
	static let defaultAltitudePreset = altitudePresets[3]
	
	static let durationPresets: [(title: String, value: NSTimeInterval)] = [
		("5 min", 5 * 60),
		("10 min", 10 * 60),
		("15 min", 15 * 60),
		("30 min", 30 * 60),
		("45 min", 45 * 60),
		("1 hr", 60 * 60),
		("1.5 hrs", 90 * 60),
		("2 hrs", 120 * 60),
		("2.5 hrs", 150 * 60),
		("3 hrs", 180 * 60),
		("3.5 hrs", 210 * 60),
		("4 hrs", 240 * 60),
		]
	
	static let defaultDurationPreset = durationPresets[5]
	
}
