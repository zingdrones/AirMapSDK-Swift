//
//  AirMap+Pilot.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/18/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

public typealias AirMap_Pilot = AirMap
extension AirMap_Pilot {
	
	/// Get a pilot by its identifier
	///
	/// - Parameters:
	///   - pilotId: The unique identifier associated with the pilot
	///   - completion: A completion handler to call with the Result
	public static func getPilot(_ pilotId: String, completion: @escaping (Result<AirMapPilot>) -> Void) {
		pilotClient.get(pilotId).subscribe(completion)
	}
	
	/// Get the currently authenticated pilot
	///
	/// - Parameter completion: A completion handler to call with the Result
	public static func getAuthenticatedPilot(_ completion: @escaping (Result<AirMapPilot>) -> Void) {
		pilotClient.getAuthenticatedPilot().subscribe(completion)
	}
	
	/// Update the currently authenticated pilot
	///
	/// - Parameters:
	///   - pilot: The pilot to update
	///   - completion: A completion handler to call with the Result
	public static func updatePilot(_ pilot: AirMapPilot, completion: @escaping (Result<AirMapPilot>) -> Void) {
		pilotClient.update(pilot).subscribe(completion)
	}
	
	/// Send an SMS verification token to the currently authenticated pilot's mobile device
	///
	/// - Parameter completion: A completion handler to call with the Result
	public static func sendSMSVerificationToken(_ completion: @escaping (Result<Void>) -> Void) {
		pilotClient.sendVerificationToken().subscribe(completion)
	}
	
	/// Verify the received SMS token submitted by the pilot
	///
	/// - Parameters:
	///   - token: The SMS token to verify
	///   - completion: A completion handler to call with the Result
	public static func verifySMS(_ token: String, completion: @escaping (Result<AirMapPilotVerified>) -> Void) {
		pilotClient.verifySMS(token: token).subscribe(completion)
	}
	
}
