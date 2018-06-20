//
//  AirMap+Traffic.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/28/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

@objc public protocol AirMapTrafficObserver: class {
	func airMapTrafficServiceDidAdd(_ traffic: [AirMapTraffic])
	func airMapTrafficServiceDidUpdate(_ traffic: [AirMapTraffic])
	func airMapTrafficServiceDidRemove(_ traffic: [AirMapTraffic])
	@objc optional func airMapTrafficServiceDidConnect()
	@objc optional func airMapTrafficServiceDidDisconnect()
	@objc optional func airMapTrafficServiceDidReceive(_ message: String)
}

extension AirMap {
	
	public static var trafficDelegate: AirMapTrafficObserver? {
		didSet { trafficService.delegate = trafficDelegate }
	}
	
	/// Suspend all active traffic alerts
	/// Typically called when the app enters the background.
	public static func suspendTraffic() {
		trafficService.disconnect()
	}
	
	/// Resume all active traffic alerts
	/// Typically called when the app enters the foreground.
	public static func resumeTraffic() {
		trafficService.connect()
	}

}
