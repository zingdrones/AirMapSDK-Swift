//
//  AirMap+Internal.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/28/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
#if AIRMAP_TELEMETRY
import CocoaAsyncSocket
#endif

typealias AirMap_Internal = AirMap
extension AirMap_Internal {

	internal static let aircraftClient = AircraftClient()
	internal static let airspaceClient = AirspaceClient()
	internal static let auth0Client = Auth0Client()
    internal static let authClient = AuthClient()
	internal static let flightClient = FlightClient()
	internal static let permitClient = PermitClient()
	internal static let pilotClient = PilotClient()
	internal static let rulesClient = RulesClient()
	internal static let statusClient = StatusClient()
	
	internal static let mappingService = MappingService()
	internal static let authSession = AirMapAuthSession()

	#if AIRMAP_TELEMETRY
	internal static let telemetryClient = AirMapTelemetry.Client()
	internal static let telemetrySocket = GCDAsyncUdpSocket()
	#endif

	#if AIRMAP_TRAFFIC
	internal static let trafficService  = TrafficService()
	#endif

	internal static let disposeBag = DisposeBag()

	internal static func hasValidCredentials() -> Bool {
		return authSession.hasValidCredentials()
	}

}
