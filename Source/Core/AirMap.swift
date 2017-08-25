//
//  AirMap.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 5/26/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

/// The principal AirMapSDK class that is extended by individual services such as Rules, Advisories, Flight, Pilot, etc.
public class AirMap {
	
	/// The current environment settings and configuration of the AirMap SDK. May be set explicity or will be lazily loaded from an airmap.config.json file
	public static var configuration: AirMapConfiguration = {
		return AirMapConfiguration.defaultConfig()
	}()

	/// A JWT auth token that identifies the logged in user accessing the service. Required for all authenticated endpoints.
	public static var authToken: String? {
		didSet { authSession.authToken = authToken }
	}
	
	/// A Boolean value, if true, will use pinned certificates to validate the AirMap server trust.  Defaults to false.
	public static var pinCertificates: Bool = false {
		didSet { authSession.enableCertificatePinning = pinCertificates }
	}

	/// Suspend all active realtime services, including traffic alerts and telemetry updates
	/// Typically called when the app enters the background.
	public static func suspend() {
		#if AIRMAP_TRAFFIC
			trafficService.disconnect()
		#endif
	}

	/// Resume all available realtime services, including traffic alerts and telemetry updates
	/// Typically called when the app enters the foreground.
	public static func resume() {
		#if AIRMAP_TRAFFIC
			trafficService.connect()
		#endif
	}
	
	private init() {}
}
