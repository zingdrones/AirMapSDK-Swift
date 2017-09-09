//
//  AirMap+Pilot.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/18/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

extension AirMap {
	
	// MARK: - Pilot

	/// Get a pilot by its identifier
	///
	/// - Parameters:
	///   - pilotId: The unique identifier associated with the pilot
	///   - completion: A completion handler to call with the Result
	public static func getPilot(_ pilotId: String, completion: @escaping (Result<AirMapPilot>) -> Void) {
		pilotClient.get(pilotId).thenSubscribe(completion)
	}
	
	/// Get the currently authenticated pilot
	///
	/// - Parameter completion: A completion handler to call with the Result
	public static func getAuthenticatedPilot(_ completion: @escaping (Result<AirMapPilot>) -> Void) {
		pilotClient.getAuthenticatedPilot().thenSubscribe(completion)
	}
	
	/// Update the currently authenticated pilot
	///
	/// - Parameters:
	///   - pilot: The pilot to update
	///   - completion: A completion handler to call with the Result
	public static func updatePilot(_ pilot: AirMapPilot, completion: @escaping (Result<AirMapPilot>) -> Void) {
		pilotClient.update(pilot).thenSubscribe(completion)
	}
	
	/// Send an SMS verification token to the currently authenticated pilot's mobile device
	///
	/// - Parameter completion: A completion handler to call with the Result
	public static func sendSMSVerificationToken(_ completion: @escaping (Result<Void>) -> Void) {
		pilotClient.sendVerificationToken().thenSubscribe(completion)
	}
	
	/// Verify the received SMS token submitted by the pilot
	///
	/// - Parameters:
	///   - token: The SMS token to verify
	///   - completion: A completion handler to call with the Result
	public static func verifySMS(_ token: String, completion: @escaping (Result<AirMapPilotVerified>) -> Void) {
		pilotClient.verifySMS(token: token).thenSubscribe(completion)
	}
	
	/// List the currently authenticated pilot's aircraft
	///
	/// - Parameter completion: A completion handler to call with the Result
	public static func listAircraft(_ completion: @escaping (Result<[AirMapAircraft]>) -> Void) {
		pilotClient.listAircraft().thenSubscribe(completion)
	}
	
	/// Create a new aircraft for the currently authenticated pilot
	///
	/// - Parameters:
	///   - aircraft: The aircraft to Create
	///   - completion: A completion handler to call with the Result
	public static func createAircraft(_ aircraft: AirMapAircraft, completion: @escaping (Result<AirMapAircraft>) -> Void) {
		pilotClient.createAircraft(aircraft).thenSubscribe(completion)
	}
	
	/// Update the provided aircraft for the currently authenticated pilot
	///
	/// - Parameters:
	///   - aircraft: The aircraft to Update
	///   - completion: A completion handler to call with the Result
	public static func updateAircraft(_ aircraft: AirMapAircraft, completion: @escaping (Result<AirMapAircraft>) -> Void) {
		pilotClient.updateAircraft(aircraft).thenSubscribe(completion)
	}
	
	/// Delete the provided aircraft for the currently authenticated pilot
	///
	/// - Parameters:
	///   - aircraft: The aircraft to delete
	///   - completion: A completion handler to call with the Result
	public static func deleteAircraft(_ aircraft: AirMapAircraft, completion: @escaping (Result<Void>) -> Void) {
		pilotClient.deleteAircraft(aircraft).thenSubscribe(completion)
	}

}
