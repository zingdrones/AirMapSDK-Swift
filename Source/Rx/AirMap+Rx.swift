//
//  AirMap.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/10/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Swift
import RxSwift

// Reactive extension for AirMap methods.
extension AirMap: ReactiveCompatible {}

/// Documentation found in AirMap+Flights.swift
extension Reactive where Base: AirMap_Flight {
	
	public static func listPublicFlights(from fromDate: Date? = nil, to toDate: Date? = nil, limit: Int? = nil) -> Observable<[AirMapFlight]> {
		return AirMap.flightClient.listPublicFlights(from: fromDate, to: toDate, limit: limit)
	}

	public static func listFlights(_ pilot: AirMapPilot, limit: Int = 100) -> Observable<[AirMapFlight]> {
		return AirMap.flightClient.list(limit: limit, pilotId: pilot.id)
	}
	
	public static func getCurrentAuthenticatedPilotFlight() -> Observable<AirMapFlight?> {
		return AirMap.flightClient.list(pilotId: AirMap.authSession.userId, startBeforeNow: true, endAfterNow: true, checkAuth: true ).map { $0.first }
	}

	public static func getFlight(_ flightId: String) -> Observable<AirMapFlight> {
		return AirMap.flightClient.get(flightId)
	}

	public static func createFlight(_ flight: AirMapFlight) -> Observable<AirMapFlight> {
		return AirMap.flightClient.create(flight)
	}

	public static func endFlight(_ flight: AirMapFlight) -> Observable<AirMapFlight> {
		return AirMap.flightClient.end(flight)
	}

	public static func deleteFlight(_ flight: AirMapFlight) -> Observable<Void> {
		return AirMap.flightClient.delete(flight)
	}
}

/// Documentation found in AirMap+Flights.swift
extension Reactive where Base: AirMap_FlightPlan {
	
	public static func createFlightPlan(_ flightPlan: AirMapFlightPlan) -> Observable<AirMapFlightPlan> {
		return AirMap.flightPlanClient.create(flightPlan)
	}

	public static func updateFlightPlan(_ flightPlan: AirMapFlightPlan) -> Observable<AirMapFlightPlan> {
		return AirMap.flightPlanClient.update(flightPlan)
	}
	
	public static func getFlightPlan(_ flightPlanId: String) -> Observable<AirMapFlightPlan> {
		return AirMap.flightPlanClient.get(flightPlanId)
	}
	
	public static func getFlightBriefing(_ flightPlanId: String) -> Observable<AirMapFlightBriefing> {
		return AirMap.flightPlanClient.getBriefing(flightPlanId)
	}
}

/// Documentation found in AirMap+Aircraft.swift
extension Reactive where Base: AirMap_Aircraft {

	public static func listAircraft() -> Observable<[AirMapAircraft]> {
		return AirMap.pilotClient.listAircraft()
	}

	public static func createAircraft(_ aircraft: AirMapAircraft) -> Observable<AirMapAircraft> {
		return AirMap.pilotClient.createAircraft(aircraft)
	}

	public static func updateAircraft(_ aircraft: AirMapAircraft) -> Observable<AirMapAircraft> {
		return AirMap.pilotClient.updateAircraft(aircraft)
	}

	public static func deleteAircraft(_ aircraft: AirMapAircraft) -> Observable<Void> {
		return AirMap.pilotClient.deleteAircraft(aircraft)
	}

	public static func listManufacturers() -> Observable<[AirMapAircraftManufacturer]> {
		return AirMap.aircraftClient.listManufacturers()
	}
	
	public static func listModels() -> Observable<[AirMapAircraftModel]> {
		return AirMap.aircraftClient.listModels()
	}
	
	public static func getModel(_ modelId: String) -> Observable<AirMapAircraftModel> {
		return AirMap.aircraftClient.getModel(modelId)
	}
}

/// Documentation found in AirMap+Pilot.swift
extension Reactive where Base: AirMap_Pilot {

	public static func getPilot(_ pilotId: String) -> Observable<AirMapPilot> {
		return AirMap.pilotClient.get(pilotId)
	}

	public static func getAuthenticatedPilot() -> Observable<AirMapPilot> {
		return AirMap.pilotClient.getAuthenticatedPilot()
	}

	public static func updatePilot(_ pilot: AirMapPilot) -> Observable<AirMapPilot> {
		return AirMap.pilotClient.update(pilot)
	}

	public static func sendSMSVerificationToken() -> Observable<Void> {
		return AirMap.pilotClient.sendVerificationToken()
	}

	public static func verifySMS(_ token: String) -> Observable<AirMapPilotVerified> {
		return AirMap.pilotClient.verifySMS(token: token)
	}
}

/// Documentation found in AirMap+Permits.swift
extension Reactive where Base: AirMap_Permits {

	public static func listPilotPermits() -> Observable<[AirMapPilotPermit]> {
		return AirMap.pilotClient.listPilotPermits()
	}

	public static func deletePilotPermit(_ pilotId: String, permit: AirMapPilotPermit) -> Observable<Void> {
		return AirMap.pilotClient.deletePilotPermit(pilotId, permit: permit)
	}

	public static func listPermits(_ permitIds: [String]? = nil, organizationId: String? = nil) -> Observable<[AirMapAvailablePermit]> {
		return AirMap.permitClient.list(permitIds, organizationId: organizationId)
	}

	public static func getAvailablePermit(_ permitId: String) -> Observable<AirMapAvailablePermit?> {
		return AirMap.permitClient.list([permitId]).map { $0.first }
	}

	public static func apply(for permit: AirMapAvailablePermit) -> Observable<AirMapPilotPermit> {
		return AirMap.permitClient.apply(for: permit)
	}

}

/// Documentation found in AirMap+Status.swift
extension Reactive where Base: AirMap_Status {

	public static func checkCoordinate(coordinate: Coordinate2D,
	                                  buffer: Meters,
	                                  types: [AirMapAirspaceType]? = nil,
	                                  ignoredTypes: [AirMapAirspaceType]? = nil,
	                                  weather: Bool = false,
	                                  date: Date = Date()) -> Observable<AirMapStatus> {

		return AirMap.statusClient.checkCoordinate(coordinate: coordinate,
		                                           buffer: buffer,
		                                           types: types,
		                                           ignoredTypes: ignoredTypes,
		                                           weather: weather,
		                                           date: date)
	}

	public static func checkFlightPath(path: [Coordinate2D],
	                                  buffer: Meters,
	                                  takeOffPoint: Coordinate2D,
	                                  types: [AirMapAirspaceType]? = nil,
	                                  ignoredTypes: [AirMapAirspaceType]? = nil,
	                                  weather: Bool = false,
	                                  date: Date = Date()) -> Observable<AirMapStatus> {

		return AirMap.statusClient.checkFlightPath(path: path,
		                                           buffer: buffer,
		                                           takeOffPoint: takeOffPoint,
		                                           types: types,
		                                           ignoredTypes: ignoredTypes,
		                                           weather: weather,
		                                           date: date)
	}

	public static func checkPolygon(geometry: [Coordinate2D],
	                               takeOffPoint: Coordinate2D,
	                               types: [AirMapAirspaceType]? = nil,
	                               ignoredTypes: [AirMapAirspaceType]? = nil,
	                               weather: Bool = false,
	                               date: Date = Date()) -> Observable<AirMapStatus> {

		return AirMap.statusClient.checkPolygon(geometry: geometry,
		                                        takeOffPoint: takeOffPoint,
		                                        types: types,
		                                        ignoredTypes: ignoredTypes,
		                                        weather: weather,
		                                        date: date)
	}

}

/// Documentation found in AirMap+Auth.swift
extension Reactive where Base: AirMap_Auth {
    
    public static func performAnonymousLogin(userId:String) -> Observable<AirMapToken> {
        
        return AirMap.authClient.performAnonymousLogin(userId: userId)
    }
	
    @available(*, unavailable)
    public static func performPhoneNumberLogin(phoneNumber:String) -> Observable<Void> {
        
        return AirMap.auth0Client.performPhoneNumberLogin(phoneNumber: phoneNumber)
    }
	
	@available(*, unavailable)
    public static func performLoginWithCode(phoneNumber:String, code:String) -> Observable<Auth0Credentials> {
        
        return AirMap.auth0Client.performLoginWithCode(phoneNumber:phoneNumber, code:code)
    }
	
}

/// Documentation found in AirMap+Rules.swift
extension Reactive where Base: AirMap_Rules {

	public static func listRules(for ruleSetIds: [String]) -> Observable<[AirMapRule]> {
		return AirMap.ruleClient.listRules(for: ruleSetIds)
	}
	
	public static func getRuleSet(by identifier: String) -> Observable<AirMapRuleSet> {
		return AirMap.ruleClient.getRuleSet(by: identifier)
	}

	public static func getRuleSets(intersecting geometry: AirMapGeometry) -> Observable<[AirMapRuleSet]> {
		return AirMap.ruleClient.getRuleSets(intersecting: geometry)
	}

}

/// Documentation found in AirMap+Advisories.swift
extension Reactive where Base: AirMap_Advisories {
	
	public static func getAirspaceStatus(geometry: AirMapGeometry, ruleSets: [AirMapRuleSet]) -> Observable<AirMapAirspaceAdvisoryStatus> {
		return AirMap.advisoryClient.getAirspaceStatus(within: geometry, under: ruleSets)
	}
	
	public static func getWeatherForecast(at coordinate: Coordinate2D, from: Date? = nil, to: Date? = nil) -> Observable<AirMapWeatherForecast> {
		return AirMap.advisoryClient.getWeatherForecast(at: coordinate, from: from, to: to)
	}
}

extension Reactive where Base: AirMap_Airspace {

	static func getAirspace(_ airspaceId: String) -> Observable<AirMapAirspace> {
		return AirMap.airspaceClient.getAirspace(airspaceId)
	}
	
	static func listAirspace(_ airspaceIds: [String]) -> Observable<[AirMapAirspace]> {
		return AirMap.airspaceClient.listAirspace(airspaceIds)
	}

}

#if AIRMAP_TRAFFIC && AIRMAP_UI
import RxCocoa

/// AirMapTrafficObserver Reactive delegate wrapper
class RxAirMapTrafficObserverProxy: DelegateProxy, DelegateProxyType {
	
	static func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
		return AirMap.trafficDelegate
	}
	
	static func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
		AirMap.trafficDelegate = delegate as? AirMapTrafficObserver
	}

}

/// Documentation found in AirMap+Traffic.swift
extension Reactive where Base: AirMap_Traffic {
	
	public static var trafficDelegate: DelegateProxy {
		return RxAirMapTrafficObserverProxy.proxyForObject(self as AnyObject)
	}
	
	public static var trafficServiceDidConnect: Observable<Bool> {
		return trafficDelegate.rx.sentMessage(#selector(AirMapTrafficObserver.airMapTrafficServiceDidConnect))
			.map { _ in return true }
	}
	
	public static var trafficServiceDidDisconnect: Observable<Bool> {
		return trafficDelegate.rx.sentMessage(#selector(AirMapTrafficObserver.airMapTrafficServiceDidDisconnect))
			.map { _ in return false }
	}
	
	public static var trafficServiceDidAdd: Observable<[AirMapTraffic]> {
		return trafficDelegate.rx.sentMessage(#selector(AirMapTrafficObserver.airMapTrafficServiceDidAdd(_:)))
			.map { $0 as! [AirMapTraffic] }
	}
	
	public static var trafficServiceDidUpdate: Observable<[AirMapTraffic]> {
		return trafficDelegate.rx.sentMessage(#selector(AirMapTrafficObserver.airMapTrafficServiceDidUpdate(_:)))
			.map { $0 as! [AirMapTraffic] }
	}
	
	public static var trafficServiceDidRemove: Observable<[AirMapTraffic]> {
		return trafficDelegate.rx.sentMessage(#selector(AirMapTrafficObserver.airMapTrafficServiceDidRemove(_:)))
			.map { $0 as! [AirMapTraffic] }
	}
	
}
#endif
