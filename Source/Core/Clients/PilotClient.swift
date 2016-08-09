//
//  DataClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/28/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift

internal class PilotClient: HTTPClient {

	init() {
		super.init(Config.AirMapApi.pilotUrl)
	}

	func get(pilotId: String) -> Observable<AirMapPilot> {
		AirMap.logger.info("GET Pilot", pilotId)
		return call(.GET, url:"/\(pilotId.urlEncoded)")
	}

	func getAuthenticatedPilot() -> Observable<AirMapPilot> {
		AirMap.logger.info("GET Authenticated Pilot", AirMap.authSession.userId)
		return call(.GET, url:"/\(AirMap.authSession.userId.urlEncoded)", authCheck: true)
	}

	func update(pilot: AirMapPilot) -> Observable<AirMapPilot> {
		AirMap.logger.info("Update Pilot", pilot)
		return call(.PATCH, url:"/\(pilot.pilotId.urlEncoded)", params: pilot.params())
	}

	func verify(token: String) -> Observable<AirMapPilotVerified> {
		AirMap.logger.info("Verify Pilot phone")
		let params = ["token" : token]
		return call(.POST, url:"/\(AirMap.authSession.userId.urlEncoded)/verify", params: params)
	}

}
typealias PilotClient_Aircraft = PilotClient
extension PilotClient {

	func listAircraft() -> Observable<[AirMapAircraft]> {
		AirMap.logger.info("List Aircraft")
		return call(.GET, url:"/\(AirMap.authSession.userId.urlEncoded)/aircraft")
	}

	func getAircraft(aircraftId: String) -> Observable<AirMapAircraft> {
		AirMap.logger.info("Get Aircraft")
		return call(.GET, url:"/\(AirMap.authSession.userId.urlEncoded)/aircraft/\(aircraftId)")
	}

	func createAircraft(aircraft: AirMapAircraft) -> Observable<AirMapAircraft> {
		AirMap.logger.info("Create Aircraft", aircraft)
		return call(.POST, url:"/\(AirMap.authSession.userId.urlEncoded)/aircraft", params: aircraft.params(), update: aircraft)
	}

	func updateAircraft(aircraft: AirMapAircraft) -> Observable<AirMapAircraft> {
		AirMap.logger.info("Update Aircraft", aircraft)
		var params = [String: AnyObject]()
		params["nickname"] = aircraft.nickname
		return call(.PATCH, url:"/\(AirMap.authSession.userId.urlEncoded)/aircraft/\(aircraft.aircraftId.urlEncoded)", params: params, update: aircraft)
	}

	func deleteAircraft(aircraft: AirMapAircraft) -> Observable<Void> {
		return call(.DELETE, url:"/\(AirMap.authSession.userId.urlEncoded)/aircraft/\(aircraft.aircraftId.urlEncoded)")
	}
}

typealias PilotClient_Permit = PilotClient
extension PilotClient {

	func listPilotPermits() -> Observable<[AirMapPilotPermit]> {
		AirMap.logger.info("List Pilot Permits")
		return call(.GET, url:"/\(AirMap.authSession.userId.urlEncoded)/permit")
	}

	func deletePilotPermit(pilotId: String, permit: AirMapPilotPermit) -> Observable<Void> {
		AirMap.logger.info("List Permits")
		return call(.DELETE, url:"/\(pilotId.urlEncoded)/permit/\(permit.permitId.urlEncoded)")
	}
}
