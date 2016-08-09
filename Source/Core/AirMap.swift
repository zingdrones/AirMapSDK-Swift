//
//  AirMap.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 5/26/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

/// AirMapSDK
@objc public class AirMap: NSObject {

	/**
	Configures the AirMap SDK

	- parameter apiKey: An API Key assigned to the developer. See http://www.airmap.com/makers
	- parameter pinCertificates: A Boolean value, if true, will use pinned certificates to validate the AirMap server trust.  Defaults to false.

	*/
	public static func configure(apiKey apiKey: String?, pinCertificates: Bool = false) {
		logger.debug(AirMap.self, "Configuring with apiKey:\(apiKey)")
		authSession.apiKey = apiKey
		authSession.enableCertificatePinning = pinCertificates
	}


	///	apiKey: An API Key assigned to the developer. See http://www.airmap.com/makers
	public static var apiKey: String? {
		didSet {
			authSession.apiKey = apiKey
		}
	}

	/// authToken: A JWT auth token that identifies the logged in user accessing the service. Required for all authenticated endpoints.

	public static var authToken: String? {
		didSet {
			authSession.authToken = authToken
		}
	}

	/// pinCertificates: A Boolean value, if true, will use pinned certificates to validate the AirMap server trust.  Defaults to false.

	public static var pinCertificates: Bool = false {
		didSet {
			authSession.enableCertificatePinning = pinCertificates
		}
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

	/**

	Returns the current airmap enviorment. // TODO: Remove for Production?

	*/
	public static func env() -> String {
		return Config.AirMapApi.env
	}

	override private init() {
		super.init()
	}

	public typealias AirMapErrorHandler = (error: NSError?) -> Void

}
