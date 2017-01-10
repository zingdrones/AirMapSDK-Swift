//
//  Config.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/24/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

struct Config {

	struct AirMapApi {

		static let host = "https://api.airmap.com"

		static var aircraftUrl: String {
            return AirMapApi.urlForResource("aircraft", version: "v2")
		}
		static var airspaceUrl: String {
			return AirMapApi.urlForResource("airspace", version: "v2")
		}
		static var flightUrl: String {
            return AirMapApi.urlForResource("flight", version: "v2")
		}
		static var permitUrl: String {
			return AirMapApi.urlForResource("permit", version: "v2")
		}
		static var pilotUrl: String {
			return AirMapApi.urlForResource("pilot", version: "v2")
		}
		static var statusUrl: String {
			return AirMapApi.urlForResource("status", version: "alpha")
		}
		static var rulesUrl: String {
			return AirMapApi.urlForResource("rules", version: "v1")
		}
		static var mapTilesUrl: String {
			return AirMapApi.urlForResource("maps", version: "v4") + "/tilejson"
		}
		static func urlForResource(named: String, version: String) -> String {
			return "\(host)/\(named)/" + (AirMap.configuration.environment ?? "\(version)")
		}

		struct Auth {
			static let ssoUrl    = "https://sso.airmap.io"
			static let scope     = "openid+offline_access"
			static let grantType = "urn:ietf:params:oauth:grant-type:jwt-bearer"
			static let keychainKeyRefreshToken = "com.airmap.airmapsdk.refresh_token"
		}
		
		static let dateFormat  = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // Ex: 2016-06-30T16:54:17.606Z
		static let smsCodeLength = 6
	}

	struct AirMapTelemetry {
		static var host: String {
// FIXME: Only supported on stage for now
//			let env = AirMap.configuration.environment ?? "prod"
//			return "api-udp-telemetry.\(env).airmap.com"
			return "api-udp-telemetry.stage.airmap.com"
		}
		static let port = UInt16(16060)
		
		struct SampleFrequency {
			static let position: NSTimeInterval = 1/5
			static let attitude: NSTimeInterval = 1/5
			static let speed: NSTimeInterval = 1/5
			static let barometer: NSTimeInterval = 5
		}
	}

	struct AirMapTraffic {
		static var host: String {
			let env = AirMap.configuration.environment ?? "prod"
			return "mqtt-\(env).airmap.io"
		}
		static let port = UInt16(8883)
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

	struct Maps {
		static let pointsPerCirclePolygon = CGFloat(90)
		static let bufferSliderLinearity: Double = 2
		static let minimumRadius: CLLocationDistance = 10
		static let maximumRadius: CLLocationDistance = 1_000
		static let feetPerMeters: Double = 3.2808
	}
	
}
