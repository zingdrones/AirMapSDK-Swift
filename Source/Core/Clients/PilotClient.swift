//
//  PilotClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/28/16.
//  Copyright 2018 AirMap, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import RxSwift

internal class PilotClient: HTTPClient {

	init() {
		super.init(basePath: Constants.Api.pilotUrl)
	}

	enum PilotClientError: Error {
		case invalidPilotIdentifier
		case invalidPilotCertificationIdentifier
		case invalidAircraftIdentifier
		case invalidAircraftRegistrationIdentifier
	}

	// MARK: Pilot

	func get(_ pilotId: AirMapPilotId) -> Observable<AirMapPilot> {
		AirMap.logger.debug("GET Pilot", metadata: ["pilot": .stringConvertible(pilotId)])
		return perform(method: .get, path: "/\(pilotId)")
	}

	func getAuthenticatedPilot() -> Observable<AirMapPilot> {
		return withCredentials().flatMap { (credentials) -> Observable<AirMapPilot> in
			AirMap.logger.debug("GET Authenticated Pilot", metadata: ["pilot": .stringConvertible(credentials.pilot)])
			return self.perform(method: .get, path: "/\(credentials.pilot)", auth: credentials)
		}
	}

	func update(_ pilot: AirMapPilot) -> Observable<AirMapPilot> {
		return withCredentials().flatMap { (credentials) -> Observable<AirMapPilot> in
			AirMap.logger.debug("Update Pilot", metadata: ["pilot": .stringConvertible(pilot.id ?? "")])
			guard let pilotId = pilot.id else { return .error(PilotClientError.invalidPilotIdentifier) }
			return self.perform(method: .patch, path: "/\(pilotId)", params: pilot.params(), update: pilot, auth: credentials)
		}
	}
	
	func sendVerificationToken() -> Observable<Void> {
		return withCredentials().flatMap { (credentials) -> Observable<Void> in
			AirMap.logger.debug("Send SMS Verification Token", metadata: ["pilot": .stringConvertible(credentials.pilot)])
			return self.perform(method: .post, path: "/\(credentials.pilot)/phone/send_token", auth: credentials)
		}
	}

	func verifySMS(token: String) -> Observable<AirMapPilotVerified> {
		return withCredentials().flatMap { (credentials) -> Observable<AirMapPilotVerified> in
			AirMap.logger.debug("Verify SMS Token", metadata: ["pilot": .stringConvertible(credentials.pilot), "token": .stringConvertible(token)])
			let params = ["token": Int(token) ?? 0]
			return self.perform(method: .post, path: "/\(credentials.pilot)/phone/verify_token", params: params, auth: credentials)
		}
	}

	// MARK: Pilot Certifications

	func listPilotCertifications() -> Observable<[AirMapPilotCertification]> {
		return withCredentials().flatMap { (credentials) -> Observable<[AirMapPilotCertification]> in
			AirMap.logger.debug("List Certifications", metadata: ["pilot": .stringConvertible(credentials.pilot)])
			return self.perform(method: .get, path: "/\(credentials.pilot)/certification", auth: credentials)
		}
	}

	func getPilotCertification(_ certificationId: AirMapPilotCertificationId) -> Observable<AirMapPilotCertification> {
		return withCredentials().flatMap { (credentials) -> Observable<AirMapPilotCertification> in
			AirMap.logger.debug("GET Certifications", metadata: ["Certification": .stringConvertible(certificationId)])
			return self.perform(method: .get, path: "/\(credentials.pilot)/certification/\(certificationId)", auth: credentials)
		}
	}

	func createPilotCertification(_ certification: AirMapPilotCertification) -> Observable<AirMapPilotCertification> {
		return withCredentials().flatMap { (credentials) -> Observable<AirMapPilotCertification> in
			AirMap.logger.debug("Create Certification", metadata: ["Pilot": .stringConvertible(credentials.pilot)])
			return self.perform(method: .post, path: "/\(credentials.pilot)/certification/", params: certification.toJSON(), update: certification, auth: credentials)
		}
	}

	func updatePilotCertification(_ certification: AirMapPilotCertification) -> Observable<AirMapPilotCertification> {
		return withCredentials().flatMap { (credentials) -> Observable<AirMapPilotCertification> in
			AirMap.logger.debug("Update Certifications", metadata: ["Certification": .stringConvertible(certification.id ?? "")])
			guard let certificationId = certification.id?.rawValue else { return .error(PilotClientError.invalidPilotCertificationIdentifier) }
			let params = ["certification_id": certification.certificationId]
			return self.perform(method: .patch, path: "/\(credentials.pilot)/certification/\(certificationId)", params: params, update: certification, auth: credentials)
		}
	}

	func deletePilotCertification(_ certificationId: AirMapPilotCertificationId) -> Observable<Void> {
		return withCredentials().flatMap { (credentials) -> Observable<Void> in
			AirMap.logger.debug("Delete Certifications", metadata: ["Certification": .stringConvertible(certificationId)])
			return self.perform(method: .delete, path: "/\(credentials.pilot)/certification/\(certificationId)", auth: credentials)
		}
	}

	// MARK: Pilot Aircraft
	
	func listAircraft() -> Observable<[AirMapAircraft]> {
		return withCredentials().flatMap { (credentials) -> Observable<[AirMapAircraft]> in
			AirMap.logger.debug("List Aircraft", metadata: ["pilot": .stringConvertible(credentials.pilot)])
			return self.perform(method: .get, path: "/\(credentials.pilot)/aircraft", auth: credentials)
		}
	}

	func getAircraft(_ aircraftId: AirMapAircraftId) -> Observable<AirMapAircraft> {
		return withCredentials().flatMap { (credentials) -> Observable<AirMapAircraft> in
			AirMap.logger.debug("GET Aircraft", metadata: ["id": .stringConvertible(aircraftId)])
			return self.perform(method: .get, path: "/\(credentials.pilot)/aircraft/\(aircraftId)", auth: credentials)
		}
	}

	func createAircraft(_ aircraft: AirMapAircraft) -> Observable<AirMapAircraft> {
		return withCredentials().flatMap { (credentials) -> Observable<AirMapAircraft> in
			AirMap.logger.debug("Create Aircraft", metadata: ["pilot": .stringConvertible(credentials.pilot)])
			return self.perform(method: .post, path: "/\(credentials.pilot)/aircraft", params: aircraft.toJSON(), update: aircraft, auth: credentials)
		}
	}

	func updateAircraft(_ aircraft: AirMapAircraft) -> Observable<AirMapAircraft> {
		return withCredentials().flatMap { (credentials) -> Observable<AirMapAircraft> in
			AirMap.logger.debug("Update Aircraft", metadata: ["id": .stringConvertible(aircraft.id ?? "")])
			guard let aircraftId = aircraft.id, let nickname = aircraft.nickname else { return .error(PilotClientError.invalidAircraftIdentifier) }
			let params = ["nickname" : nickname]
			return self.perform(method: .patch, path: "/\(credentials.pilot)/aircraft/\(aircraftId)", params: params, update: aircraft, auth: credentials)
		}
	}

	func deleteAircraft(_ aircraft: AirMapAircraft) -> Observable<Void> {
		return withCredentials().flatMap { (credentials) -> Observable<Void> in
			AirMap.logger.debug("Delete Aircraft", metadata: ["id": .stringConvertible(aircraft.id ?? "")])
			guard let aircraftId = aircraft.id else { return .error(PilotClientError.invalidAircraftIdentifier) }
			return self.perform(method: .delete, path: "/\(credentials.pilot)/aircraft/\(aircraftId)", auth: credentials)
		}
	}

	// MARK: Aircraft Registrations

	func listAircraftRegistrations(_ aircraft: AirMapAircraft) -> Observable<[AirMapAircraftRegistration]> {
		return withCredentials().flatMap { (credentials) -> Observable<[AirMapAircraftRegistration]> in
			AirMap.logger.debug("List registrations", metadata: ["registration": .stringConvertible(aircraft.id ?? "")])
			guard let aircraftId = aircraft.id else { return .error(PilotClientError.invalidAircraftIdentifier) }
			return self.perform(method: .get, path: "/\(credentials.pilot)/aircraft/\(aircraftId.rawValue)/registration", auth: credentials)
		}
	}

	func getAircraftRegistration(_ registrationId: AirMapAircraftRegistrationId, _ aircraftId: AirMapAircraftId) -> Observable<AirMapAircraftRegistration> {
		return withCredentials().flatMap { (credentials) -> Observable<AirMapAircraftRegistration> in
			AirMap.logger.debug("GET registration", metadata: ["registration": .stringConvertible(registrationId)])
			return self.perform(method: .get, path: "/\(credentials.pilot)/aircraft/\(aircraftId)/registration/\(registrationId)", auth: credentials)
		}
	}

	func createAircraftRegistration(_ registration: AirMapAircraftRegistration, _ aircraftId: AirMapAircraftId) -> Observable<AirMapAircraftRegistration> {
		return withCredentials().flatMap { (credentials) -> Observable<AirMapAircraftRegistration> in
			AirMap.logger.debug("Create registration", metadata: ["registration": .stringConvertible(registration.id ?? "")])
			return self.perform(method: .post, path: "/\(credentials.pilot)/aircraft/\(aircraftId)/registration", params: registration.toJSON(), update: registration, auth: credentials)
		}
	}

	func updateAircraftRegistration(_ registration: AirMapAircraftRegistration) -> Observable<AirMapAircraftRegistration> {
		return withCredentials().flatMap { (credentials) -> Observable<AirMapAircraftRegistration> in
			AirMap.logger.debug("Update registration", metadata: ["registration": .stringConvertible(registration.id ?? "")])
			guard let aircraftRegistrationId = registration.id, let aircraftId = registration.aircraftId else { return .error(PilotClientError.invalidAircraftRegistrationIdentifier) }
			return self.perform(method: .patch, path: "/\(credentials.pilot)/aircraft/\(aircraftId)/registration/\(aircraftRegistrationId)", params: registration.toJSON(), update: registration, auth: credentials)
		}
	}

	func deleteAircraftRegistration(_ registrationId: AirMapAircraftRegistrationId, _ aircraftId: AirMapAircraftId) -> Observable<Void> {
		return withCredentials().flatMap { (credentials) -> Observable<Void> in
			AirMap.logger.debug("Delete Registration", metadata: ["id": .stringConvertible(registrationId)])
			return self.perform(method: .delete, path: "/\(credentials.pilot)/aircraft/\(aircraftId)/registration/\(registrationId)", auth: credentials)
		}
	}
}
