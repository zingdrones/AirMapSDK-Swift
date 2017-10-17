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

extension Reactive where Base: AirMap {
	
	public static var networkActivity: ActivityTracker {
		return HTTPClient.activity
	}
}

/// Documentation found in AirMap+Flights.swift
extension Reactive where Base: AirMap {
	
	public static func listPublicFlights(from fromDate: Date? = nil, to toDate: Date? = nil, limit: Int? = nil, within geometry: AirMapGeometry? = nil) -> Observable<[AirMapFlight]> {
		return AirMap.flightClient.listPublicFlights(from: fromDate, to: toDate, limit: limit, within: geometry)
	}

	public static func listFlights(_ pilot: AirMapPilot, from: Date? = nil, to: Date? = nil, limit: Int = 100) -> Observable<[AirMapFlight]> {
		return AirMap.flightClient.list(limit: limit, pilotId: pilot.id, startBefore: to, endAfter: from)
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
	
	public static func getFlightPlanByFlightId(_ id: String) -> Observable<AirMapFlightPlan> {
		return AirMap.flightClient.getFlightPlanByFlightId(id)
	}
}

/// Documentation found in AirMap+Flights.swift
extension Reactive where Base: AirMap {
	
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
	
	public static func submitFlightPlan(_ flightPlanId: String) -> Observable<AirMapFlightPlan> {
		return AirMap.flightPlanClient.submitFlightPlan(flightPlanId)
	}
}

/// Documentation found in AirMap+Aircraft.swift
extension Reactive where Base: AirMap {

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
	
	public static func searchManufacturers(by name: String) -> Observable<[AirMapAircraftManufacturer]> {
		return AirMap.aircraftClient.searchManufacturers(by: name)
	}
	
	public static func listModels(by manufacturerId: String) -> Observable<[AirMapAircraftModel]> {
		return AirMap.aircraftClient.listModels(by: manufacturerId)
	}
	
	public static func searchModels(by name: String) -> Observable<[AirMapAircraftModel]> {
		return AirMap.aircraftClient.searchModels(by: name)
	}
	
	public static func getModel(_ modelId: String) -> Observable<AirMapAircraftModel> {
		return AirMap.aircraftClient.getModel(modelId)
	}
}

/// Documentation found in AirMap+Pilot.swift
extension Reactive where Base: AirMap {

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

/// Documentation found in AirMap+Auth.swift
extension Reactive where Base: AirMap {
    
    public static func performAnonymousLogin(userId:String) -> Observable<AirMapToken> {
        return AirMap.authClient.performAnonymousLogin(userId: userId)
    }
	
	public static func startPasswordlessLogin(with phoneNumber: String) -> Observable<Void> {
        return AirMap.auth0Client.startPasswordlessLogin(with: phoneNumber)
    }
	
    public static func verifyPasswordlessLogin(with phoneNumber: String, code: String) -> Observable<Auth0Credentials> {
        return AirMap.auth0Client.verifyPasswordlessLogin(with: phoneNumber, code: code)
    }
}

/// Documentation found in AirMap+Rules.swift
extension Reactive where Base: AirMap {

	public static func getRulesets(by rulesetIds: [String]) -> Observable<[AirMapRuleset]> {
		return AirMap.ruleClient.getRulesets(by: rulesetIds)
	}
	
	public static func getRuleset(by identifier: String) -> Observable<AirMapRuleset> {
		return AirMap.ruleClient.getRuleset(by: identifier)
	}
	
	public static func getRulesetsEvaluated(by flightPlanId: String) -> Observable<[AirMapFlightBriefing.Ruleset]> {
		return AirMap.ruleClient.getRulesetsEvaluated(by: flightPlanId)
	}

	public static func getRulesetsEvaluated(from geometry: AirMapPolygon, rulesetIds: [String], flightFeatureValues: [String: Any]?) -> Observable<[AirMapFlightBriefing.Ruleset]> {
		return AirMap.ruleClient.getRulesetsEvaluated(from: geometry, rulesetIds: rulesetIds, flightFeatureValues: flightFeatureValues)
	}

	public static func getRulesets(intersecting geometry: AirMapGeometry) -> Observable<[AirMapRuleset]> {
		return AirMap.ruleClient.getRulesets(intersecting: geometry)
	}
}

/// Documentation found in AirMap+Advisories.swift
extension Reactive where Base: AirMap {
	
	public static func getAirspaceStatus(geometry: AirMapGeometry, rulesetIds: [String], from start: Date? = nil, to end: Date? = nil) -> Observable<AirMapAirspaceStatus> {
		return AirMap.advisoryClient.getAirspaceStatus(within: geometry, under: rulesetIds, from: start, to: end)
	}
	
	public static func getWeatherForecast(at coordinate: Coordinate2D, from: Date? = nil, to: Date? = nil) -> Observable<AirMapWeather> {
		return AirMap.advisoryClient.getWeatherForecast(at: coordinate, from: from, to: to)
	}
}

extension Reactive where Base: AirMap {

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
extension Reactive where Base: AirMap {
	
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
