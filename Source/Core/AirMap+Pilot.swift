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
	public static func createAircraft(_ aircraft: inout AirMapAircraft, completion: @escaping (Result<AirMapAircraft>) -> Void) {
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
