//
//  AirMapUIConstants.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/18/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

public struct UIConstants {
		
	public static let flightDistanceFormatter: LengthFormatter = {
		let f = LengthFormatter()
		f.unitStyle = .medium
		f.numberFormatter.maximumFractionDigits = 0
		f.numberFormatter.roundingIncrement = 5
		return f
	}()

	public static let flightDurationFormatter: DateComponentsFormatter = {
		let f = DateComponentsFormatter()
		f.allowedUnits = [.hour, .minute]
		f.allowsFractionalUnits = false
		f.collapsesLargestUnit = true
		f.unitsStyle = .abbreviated
		f.zeroFormattingBehavior = .dropAll
		return f
	}()

	public static let altitudePresetsImperial: [Meters] = [
		15.24,  //  50 ft
		30.48,  // 100 ft
		60.96,  // 200 ft
		91.44,  // 300 ft
		121.92, // 400 ft
		152.4   // 500 ft
		]
	public static let defaultAltitudePresetImperial = altitudePresetsImperial[3]

	public static let altitudePresetsMetric: [Meters] = [25, 50, 75, 100, 150]
	public static let defaultAltitudePresetMetric = altitudePresetsMetric[3]

	public static let durationPresets: [TimeInterval] = [5, 10, 15, 30, 45, 60, 90, 120, 150, 180, 210, 240].map { $0 * 60 }
	public static let defaultDurationPreset = durationPresets[5]
}
