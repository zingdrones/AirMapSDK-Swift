//
//  AirMapAnalytics.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 12/16/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
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

enum AnalyticsAction: String {
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

protocol AnalyticsTrackable {
	
	var screenName: String { get }
}

extension AnalyticsTrackable {
	
	func trackView() {
		AirMapAnalytics.delegate?.analyticsDidTrackScreen(screenName)
	}
	
	func trackEvent(_ action: AnalyticsAction, label: String, value: NSNumber? = nil) {
		AirMapAnalytics.delegate?.analyticsDidTrackEvent(screenName, action: action.rawValue, label: label, value: value)
	}
}
