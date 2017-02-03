//
//  AirMap+Flights.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/28/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

public typealias AirMap_Permits = AirMap
extension AirMap_Permits {

	/// List all pilot permits for the currently authenticated pilot
	///
	/// - Parameter completion: A completion handler to call with the Result
	public static func listPilotPermits(_ completion: @escaping (Result<[AirMapPilotPermit]>) -> Void) {
		pilotClient.listPilotPermits().subscribe(completion)
	}
	
	/// Delete a pilot permit associated with the currently authenticated pilot
	///
	/// - Parameters:
	///   - pilotId: The unique identifier associated with the currently authenticated pilot
	///   - permit: The permit to delete
	///   - completion: A completion handler to call with the Result
	public static func deletePilotPermit(_ pilotId: String, permit: AirMapPilotPermit, completion: @escaping (Result<Void>) -> Void) {
		pilotClient.deletePilotPermit(pilotId, permit: permit).subscribe(completion)
	}
	
	/// List available permits for a given organization identifier or permit id(s)
	///
	/// - Parameters:
	///   - permitIds: The available permit ids to list
	///   - organizationId: The organization for which to list availble permits
	///   - completion: A completion handler to call with the Result
	public static func listPermits(_ permitIds: [String]? = nil, organizationId: String? = nil, completion: @escaping (Result<[AirMapAvailablePermit]>) -> Void) {
		permitClient.list(permitIds, organizationId: organizationId).subscribe(completion)
	}
	
	/// Get details for an available permit referenced by its identifier
	///
	/// - Parameters:
	///   - permitId: The uniqued identifier associated with the available permit
	///   - completion: A completion handler to call with the Result
	public static func getAvailablePermit(_ permitId: String, completion: @escaping (Result<AirMapAvailablePermit?>) -> Void) {
		return permitClient.list([permitId]).map { $0.first }.subscribe(completion)
	}
	
	/// Apply for an available permit, returning a pilot permit.
	///
	/// - Parameters:
	///   - permit: The available permit to apply for
	///   - completion: A completion handler to call with the Result
	public static func applyForPermit(_ permit: AirMapAvailablePermit, completion: @escaping (Result<AirMapPilotPermit>) -> Void) {
		permitClient.apply(for: permit).subscribe(completion)
	}

}
