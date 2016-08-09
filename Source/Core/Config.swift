//
//  Config.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/24/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

struct Config {

	struct AirMapApi {
		static let env = "stage"
		static let host = "https://api.airmap.io"
		static let aircraftUrl = host + "/aircraft/" + env
		static let pilotUrl    = host + "/pilot/"    + env
		static let flightUrl   = host + "/flight/"   + env
		static let permitUrl   = host + "/permit/"   + env
		static let statusUrl   = host + "/status/"   + env
		static let mapTilesUrl = host + "/maps/v4/tilejson"

		struct Auth {
			static let callbackUrlHost = "localhost"
			static let callbackUrlPort = 8080
			static let callbackUrlPath = "/login"
			static let loginUrl = "https://sso.airmap.io/authorize?response_type=token&client_id=2iV1XSfdLJNOfZiTZ9JGdrNHtcNzYstt&redirect_uri=https://\(Auth.callbackUrlHost):\(Auth.callbackUrlPort)\(Auth.callbackUrlPath)&scope=openid+offline_access"
		}
		static let dateFormat  = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // Ex: 2016-06-30T16:54:17.606Z
		static let smsCodeLength = 6
	}

	struct AirMapTelemetry {
		static let host = "ec2-54-186-255-126.us-west-2.compute.amazonaws.com"
		static let port = UInt16(8000)
	}

	struct AirMapTraffic {
		static let host = "ec2-54-218-56-69.us-west-2.compute.amazonaws.com"
		static let port = UInt16(1883)
		static let keepAlive = UInt16(15)
		static let expirationInterval = NSTimeInterval(30)
		static let trafficAlertChannel = "uav/traffic/alert/"
		static let trafficSituationalAwarenessChannel = "uav/traffic/sa/"
		#if os(OSX)
		static let clientId = "macOS AirMap SDK" // TODO: Create a unique id for macOS clients
		#else
		static let clientId = UIDevice.currentDevice().identifierForVendor!.UUIDString
		#endif
	}
}
