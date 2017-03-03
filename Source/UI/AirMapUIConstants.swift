//
//  AirMapUIConstants.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/18/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

struct UIConstants {
		
	static let flightDistanceFormatter: LengthFormatter = {
		let f = LengthFormatter()
		f.unitStyle = .short
		f.numberFormatter.maximumFractionDigits = 0
		f.numberFormatter.roundingIncrement = 5
		return f
	}()

	static let flightDurationFormatter: DateComponentsFormatter = {
		let f = DateComponentsFormatter()
		f.allowedUnits = [.hour, .minute]
		f.allowsFractionalUnits = false
		f.collapsesLargestUnit = true
		f.unitsStyle = .abbreviated
		f.zeroFormattingBehavior = .dropAll
		return f
	}()

	static let altitudePresetsImperial: [Meters] = [
		15.24,  //  50 ft
		30.48,  // 100 ft
		60.96,  // 200 ft
		91.44,  // 300 ft
		121.92, // 400 ft
		152.4   // 500 ft
		]
	static let defaultAltitudePresetImperial = altitudePresetsImperial[3]

	static let altitudePresetsMetric: [Meters] = [25, 50, 75, 100, 150]
	static let defaultAltitudePresetMetric = altitudePresetsMetric[3]

	static let durationPresets: [TimeInterval] = [5, 10, 15, 30, 45, 60, 90, 120, 150, 180, 210, 240].map { $0 * 60 }
	static let defaultDurationPreset = durationPresets[5]
}
