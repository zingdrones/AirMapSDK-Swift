//
//  PilotClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/28/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation
import RxSwift

internal class PilotClient: HTTPClient {

	init() {
		super.init(basePath: Config.AirMapApi.pilotUrl)
	}

	func get(_ pilotId: String) -> Observable<AirMapPilot> {
		AirMap.logger.debug("GET Pilot", pilotId)
		return perform(method: .get, path:"/\(pilotId)")
	}

	func getAuthenticatedPilot() -> Observable<AirMapPilot> {
		AirMap.logger.debug("GET Authenticated Pilot", AirMap.authSession.userId)
		return perform(method: .get, path:"/\(AirMap.authSession.userId)", checkAuth: true)
	}

	func update(_ pilot: AirMapPilot) -> Observable<AirMapPilot> {
		AirMap.logger.debug("Update Pilot", pilot)
		return perform(method: .patch, path:"/\(pilot.id ?? "")", params: pilot.params())
	}
	
	func sendVerificationToken() -> Observable<Void> {
		AirMap.logger.debug("Send Phone Number SMS Verification Token")
		return perform(method: .post, path:"/\(AirMap.authSession.userId)/phone/send_token")
	}

	func verifySMS(token: String) -> Observable<AirMapPilotVerified> {
		AirMap.logger.debug("Verify SMS Token")
		let params = ["token": Int(token) ?? 0]
		return perform(method: .post, path:"/\(AirMap.authSession.userId)/phone/verify_token", params: params)
	}
}

typealias PilotClient_Aircraft = PilotClient
extension PilotClient_Aircraft {

	func listAircraft() -> Observable<[AirMapAircraft]> {
		AirMap.logger.debug("List Aircraft")
		return perform(method: .get, path:"/\(AirMap.authSession.userId)/aircraft")
	}

	func getAircraft(_ aircraftId: String) -> Observable<AirMapAircraft> {
		AirMap.logger.debug("Get Aircraft")
		return perform(method: .get, path:"/\(AirMap.authSession.userId)/aircraft/\(aircraftId)")
	}

	func createAircraft(_ aircraft: AirMapAircraft) -> Observable<AirMapAircraft> {
		AirMap.logger.debug("Create Aircraft", aircraft)
		return perform(method: .post, path:"/\(AirMap.authSession.userId)/aircraft", params: aircraft.params(), update: aircraft)
	}

	func updateAircraft(_ aircraft: AirMapAircraft) -> Observable<AirMapAircraft> {
		AirMap.logger.debug("Update Aircraft", aircraft)
		let params = ["nickname": aircraft.nickname as Any]
		return perform(method: .patch, path:"/\(AirMap.authSession.userId)/aircraft/\(aircraft.id ?? "")", params: params, update: aircraft)
	}

	func deleteAircraft(_ aircraft: AirMapAircraft) -> Observable<Void> {
		AirMap.logger.debug("Delete Aircraft", aircraft)
		return perform(method: .delete, path:"/\(AirMap.authSession.userId)/aircraft/\(aircraft.id ?? "")")
	}
}
