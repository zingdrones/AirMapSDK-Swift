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
		super.init(basePath: Constants.AirMapApi.pilotUrl)
	}

	enum PilotClientError: Error {
		case invalidPilotIdentifier
		case invalidAircraftIdentifier
	}

	// MARK: Pilot

	func get(_ pilotId: String) -> Observable<AirMapPilot> {
		AirMap.logger.debug("GET Pilot", pilotId)
		return perform(method: .get, path: "/\(pilotId)")
	}

	func getAuthenticatedPilot() -> Observable<AirMapPilot> {
		AirMap.logger.debug("GET Authenticated Pilot", AirMap.authSession.userId)
		return perform(method: .get, path: "/\(AirMap.authSession.userId)", checkAuth: true)
	}

	func update(_ pilot: AirMapPilot) -> Observable<AirMapPilot> {
		AirMap.logger.debug("Update Pilot", pilot)
		guard let pilotId = pilot.id else { return .error(PilotClientError.invalidPilotIdentifier) }
		return perform(method: .patch, path: "/\(pilotId)", params: pilot.params(), checkAuth: true)
	}
	
	func sendVerificationToken() -> Observable<Void> {
		AirMap.logger.debug("Send Phone Number SMS Verification Token")
		return perform(method: .post, path: "/\(AirMap.authSession.userId)/phone/send_token")
	}

	func verifySMS(token: String) -> Observable<AirMapPilotVerified> {
		AirMap.logger.debug("Verify SMS Token")
		let params = ["token": Int(token) ?? 0]
		return perform(method: .post, path: "/\(AirMap.authSession.userId)/phone/verify_token", params: params)
	}

	// MARK: Aircraft
	
	func listAircraft() -> Observable<[AirMapAircraft]> {
		AirMap.logger.debug("List Aircraft")
		return perform(method: .get, path: "/\(AirMap.authSession.userId)/aircraft", checkAuth: true)
	}

	func getAircraft(_ aircraftId: String) -> Observable<AirMapAircraft> {
		AirMap.logger.debug("Get Aircraft")
		return perform(method: .get, path: "/\(AirMap.authSession.userId)/aircraft/\(aircraftId)", checkAuth: true)
	}

	func createAircraft(_ aircraft: AirMapAircraft) -> Observable<AirMapAircraft> {
		AirMap.logger.debug("Create Aircraft", aircraft)
		return perform(method: .post, path: "/\(AirMap.authSession.userId)/aircraft", params: aircraft.toJSON(), update: aircraft, checkAuth: true)
	}

	func updateAircraft(_ aircraft: AirMapAircraft) -> Observable<AirMapAircraft> {
		AirMap.logger.debug("Update Aircraft", aircraft)
		guard let aircraftId = aircraft.id else { return .error(PilotClientError.invalidAircraftIdentifier) }
		return perform(method: .patch, path: "/\(AirMap.authSession.userId)/aircraft/\(aircraftId)", params: aircraft.toJSON(), update: aircraft, checkAuth: true)
	}

	func deleteAircraft(_ aircraft: AirMapAircraft) -> Observable<Void> {
		AirMap.logger.debug("Delete Aircraft", aircraft)
		guard let aircraftId = aircraft.id else { return .error(PilotClientError.invalidAircraftIdentifier) }
		return perform(method: .delete, path: "/\(AirMap.authSession.userId)/aircraft/\(aircraftId)", checkAuth: true)
	}
}
