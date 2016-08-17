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
		AirMap.logger.debug("GET Pilot", pilotId)
		return call(.GET, url:"/\(pilotId)")
	}

	func getAuthenticatedPilot() -> Observable<AirMapPilot> {
		AirMap.logger.debug("GET Authenticated Pilot", AirMap.authSession.userId)
		return call(.GET, url:"/\(AirMap.authSession.userId)", authCheck: true)
	}

	func update(pilot: AirMapPilot) -> Observable<AirMapPilot> {
		AirMap.logger.debug("Update Pilot", pilot)
		return call(.PATCH, url:"/\(pilot.pilotId)", params: pilot.params())
	}
	
	func sendVerificationToken() -> Observable<Void> {
		AirMap.logger.debug("Send Phone Number SMS Verification Token")
		return call(.POST, url:"/\(AirMap.authSession.userId)/phone/send_token")
	}

	func verifySMS(token: String) -> Observable<AirMapPilotVerified> {
		AirMap.logger.debug("Verify SMS Token")
		let params = ["token": Int(token) ?? 0]
		return call(.POST, url:"/\(AirMap.authSession.userId)/phone/verify_token", params: params)
	}

}

typealias PilotClient_Aircraft = PilotClient
extension PilotClient {

	func listAircraft() -> Observable<[AirMapAircraft]> {
		AirMap.logger.debug("List Aircraft")
		return call(.GET, url:"/\(AirMap.authSession.userId)/aircraft")
	}

	func getAircraft(aircraftId: String) -> Observable<AirMapAircraft> {
		AirMap.logger.debug("Get Aircraft")
		return call(.GET, url:"/\(AirMap.authSession.userId)/aircraft/\(aircraftId)")
	}

	func createAircraft(aircraft: AirMapAircraft) -> Observable<AirMapAircraft> {
		AirMap.logger.debug("Create Aircraft", aircraft)
		return call(.POST, url:"/\(AirMap.authSession.userId)/aircraft", params: aircraft.params(), update: aircraft)
	}

	func updateAircraft(aircraft: AirMapAircraft) -> Observable<AirMapAircraft> {
		AirMap.logger.debug("Update Aircraft", aircraft)
		var params = [String: AnyObject]()
		params["nickname"] = aircraft.nickname
		return call(.PATCH, url:"/\(AirMap.authSession.userId)/aircraft/\(aircraft.aircraftId)", params: params, update: aircraft)
	}

	func deleteAircraft(aircraft: AirMapAircraft) -> Observable<Void> {
		AirMap.logger.debug("Delete Aircraft", aircraft)
		return call(.DELETE, url:"/\(AirMap.authSession.userId)/aircraft/\(aircraft.aircraftId)")
	}
}

typealias PilotClient_Permit = PilotClient
extension PilotClient {

	func listPilotPermits() -> Observable<[AirMapPilotPermit]> {
		AirMap.logger.debug("List Pilot Permits")
		return call(.GET, url:"/\(AirMap.authSession.userId)/permit")
	}

	func deletePilotPermit(pilotId: String, permit: AirMapPilotPermit) -> Observable<Void> {
		AirMap.logger.debug("Delete Pilot Permit")
		return call(.DELETE, url:"/\(pilotId)/permit/\(permit.permitId)")
	}
}
