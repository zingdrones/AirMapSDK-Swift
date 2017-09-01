//
//  AirMap+Traffic.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/28/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

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
	
}
