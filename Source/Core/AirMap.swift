//
//  AirMap.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 5/26/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

public class AirMap: NSObject {
	
	public static var configuration = AirMapConfiguration.loadConfig()

	/**
	
	A JWT auth token that identifies the logged in user accessing the service. Required for all authenticated endpoints.
	
	*/
	public static var authToken: String? {
		didSet { authSession.authToken = authToken }
	}

	/**
	
	A Boolean value, if true, will use pinned certificates to validate the AirMap server trust.  Defaults to false.
	
	*/
	public static var pinCertificates: Bool = false {
		didSet { authSession.enableCertificatePinning = pinCertificates }
	}

	/**

	Suspend all active realtime services, including traffic alerts and telemetry updates
	Typically called when the app enters the background.

	*/
	public static func suspend() {
		#if AIRMAP_TRAFFIC
			trafficService.disconnect()
		#endif
	}

	/**

	Resume all available realtime services, including traffic alerts and telemetry updates
	Typically called when the app enters the foreground.

	*/
	public static func resume() {
		#if AIRMAP_TRAFFIC
			trafficService.connect()
		#endif
	}
	
	override private init() {
		super.init()
	}
	
	public typealias AirMapErrorHandler = (error: NSError?) -> Void

}
