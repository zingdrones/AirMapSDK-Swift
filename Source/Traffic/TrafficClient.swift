//
//  TrafficClient.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/2/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import SwiftMQTT
import ObjectMapper

internal class TrafficClient: MQTTSession {
	
	init() {
		super.init(
			host: Constants.AirMapTraffic.host,
			port: Constants.AirMapTraffic.port,
			clientID: Constants.AirMapTraffic.clientId,
			cleanSession: true,
			keepAlive: Constants.AirMapTraffic.keepAlive,
			useSSL: true
		)
	}
	var currentChannels = [String]()
	
	deinit {
		disconnect()
	}
	
}
