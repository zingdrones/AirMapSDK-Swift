//
//  AirMapAnalytics.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 12/16/16.
//  Copyright 2018 AirMap, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

public protocol AirMapAnalyticsDelegate: class {
	
	func analyticsDidTrackScreen(_ screen: String)
	func analyticsDidTrackEvent(_ category: String, action: String, label: String, value: NSNumber?)
}

public class AirMapAnalytics {
	
	public static weak var delegate: AirMapAnalyticsDelegate?
	
	internal static func trackEvent(_ category: String, action: AnalyticsAction, label: String, value: NSNumber? = nil) {
		delegate?.analyticsDidTrackEvent(category, action: action.rawValue, label: label, value: value)
	}
}

public enum AnalyticsAction: String {
	case tap
	case slide
	case swipe
	case drag
	case drop
	case zoom
	case next
	case draw
	case toggle
	case save
	case delete
}

public protocol AnalyticsTrackable {
	
	var screenName: String { get }
}

public extension AnalyticsTrackable {
	
	func trackView() {
		AirMapAnalytics.delegate?.analyticsDidTrackScreen(screenName)
	}
	
	func trackEvent(_ action: AnalyticsAction, label: String, value: NSNumber? = nil) {
		AirMapAnalytics.delegate?.analyticsDidTrackEvent(screenName, action: action.rawValue, label: label, value: value)
	}
}
