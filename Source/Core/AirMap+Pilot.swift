//
//  AirMap+Pilot.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/18/16.
/*
Copyright 2018 AirMap, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
//

extension AirMap {
	
	// MARK: - Pilot

	/// Get a pilot by its identifier
	///
	/// - Parameters:
	///   - id: The unique identifier associated with the pilot
	///   - completion: A completion handler to call with the Result
	public static func getPilot(by id: AirMapPilotId, completion: @escaping (Result<AirMapPilot>) -> Void) {
		rx.getPilot(by: id).thenSubscribe(completion)
	}
	
	/// Get the currently authenticated pilot
	///
	/// - Parameter completion: A completion handler to call with the Result
	public static func getAuthenticatedPilot(_ completion: @escaping (Result<AirMapPilot>) -> Void) {
		rx.getAuthenticatedPilot().thenSubscribe(completion)
	}
	
	/// Update the currently authenticated pilot
	///
	/// - Parameters:
	///   - pilot: The pilot to update
	///   - completion: A completion handler to call with the Result
	public static func updatePilot(_ pilot: AirMapPilot, completion: @escaping (Result<AirMapPilot>) -> Void) {
		rx.updatePilot(pilot).thenSubscribe(completion)
	}
	
	/// Send an SMS verification token to the currently authenticated pilot's mobile device
	///
	/// - Parameter completion: A completion handler to call with the Result
	public static func sendSMSVerificationToken(_ completion: @escaping (Result<Void>) -> Void) {
		rx.sendSMSVerificationToken().thenSubscribe(completion)
	}
	
	/// Verify the received SMS token submitted by the pilot
	///
	/// - Parameters:
	///   - token: The SMS token to verify
	///   - completion: A completion handler to call with the Result
	public static func verifySMS(_ token: String, completion: @escaping (Result<AirMapPilotVerified>) -> Void) {
		rx.verifySMS(token).thenSubscribe(completion)
	}
	
	/// List the currently authenticated pilot's aircraft
	///
	/// - Parameter completion: A completion handler to call with the Result
	public static func listAircraft(_ completion: @escaping (Result<[AirMapAircraft]>) -> Void) {
		rx.listAircraft().thenSubscribe(completion)
	}
	
	/// Create a new aircraft for the currently authenticated pilot
	///
	/// - Parameters:
	///   - aircraft: The aircraft to Create
	///   - completion: A completion handler to call with the Result
	public static func createAircraft(_ aircraft: AirMapAircraft, completion: @escaping (Result<AirMapAircraft>) -> Void) {
		rx.createAircraft(aircraft).thenSubscribe(completion)
	}
	
	/// Update the provided aircraft for the currently authenticated pilot
	///
	/// - Parameters:
	///   - aircraft: The aircraft to Update
	///   - completion: A completion handler to call with the Result
	public static func updateAircraft(_ aircraft: AirMapAircraft, completion: @escaping (Result<AirMapAircraft>) -> Void) {
		rx.updateAircraft(aircraft).thenSubscribe(completion)
	}
	
	/// Delete the provided aircraft for the currently authenticated pilot
	///
	/// - Parameters:
	///   - aircraft: The aircraft to delete
	///   - completion: A completion handler to call with the Result
	public static func deleteAircraft(_ aircraft: AirMapAircraft, completion: @escaping (Result<Void>) -> Void) {
		rx.deleteAircraft(aircraft).thenSubscribe(completion)
	}

}
