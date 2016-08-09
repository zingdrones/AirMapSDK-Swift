//
//  AirMap+Pilot.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/18/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

private typealias AirMap_Pilot = AirMap
extension AirMap_Pilot {
	
	public typealias AirMapPilotPermitCollectionHandler = ([AirMapPilotPermit]?, NSError?) -> Void
	public typealias AirMapPilotHandler = (AirMapPilot?, NSError?) -> Void
	public typealias AirMapPilotVerificationResponseHandler = (AirMapPilotVerified?, NSError?) -> Void
	
	/**
	
	Get a pilot by id
	
	- parameter pilotId: The Identifier of the Pilot
	- parameter handler: `(AirMapPilot?, NSError?) -> Void`
	
	*/
	public class func getPilot(pilotId: String, handler: AirMapPilotHandler) {
		pilotClient.get(pilotId).subscribe(handler)
	}
	
	/*
	
	Get the authenticated pilot
	
	- parameter handler: `(AirMapPilot?, NSError?) -> Void`
	
	*/
	public class func getAuthenticatedPilot(handler: AirMapPilotHandler) {
		pilotClient.getAuthenticatedPilot().subscribe(handler)
	}
	
	/**
	
	Update a pilot
	
	- parameter pilot: The `AirMapPilot` to update
	- parameter handler: `(AirMapPilot?, NSError?) -> Void`
	
	*/
	public class func updatePilot(pilot: AirMapPilot, handler: AirMapPilotHandler) {
		pilotClient.update(pilot).subscribe(handler)
	}
	
	/**
	
	List Pilot Permits for authenticated user
	
	- parameter handler: `([AirMapPilotPermit]?, NSError?) -> Void`
	
	*/
	public class func listPilotPermits(handler: AirMapPilotPermitCollectionHandler) {
		pilotClient.listPilotPermits().subscribe(handler)
	}
	
	/**
	
	Delete Pilot Permit
	
	- parameter pilot: The `pilotId` String
	- parameter pilot: The `AirMapPilotPermit`
	- parameter handler: `(AirMapPilot?, NSError?) -> Void`
	
	*/
	public class func deletePilotPermit(pilotId: String, permit: AirMapPilotPermit, handler: AirMapErrorHandler) {
		pilotClient.deletePilotPermit(pilotId, permit: permit).subscribe(handler)
	}
	
	/**
	
	Verify Token
	
	- parameter token: `String` The token sent to the device
	- parameter handler: `(AirMapPilot?, NSError?) -> Void`
	
	*/
	public class func verify(token: String, handler: AirMapPilotVerificationResponseHandler) {
		pilotClient.verify(token).subscribe(handler)
	}
	
}


private typealias AirMap_Aircraft = AirMap
extension AirMap_Aircraft {
	
	public typealias AirMapAircraftHandler = (AirMapAircraft?, NSError?) -> Void
	public typealias AirMapAircraftCollectionHandler = ([AirMapAircraft]?, NSError?) -> Void
	public typealias AirMapAircraftErrorHandler = (error: NSError?) -> Void
	
	/**
	
	List authenticated users aircraft
	
	- parameter id: `String`
	- parameter handler: `(AirMapAircraft?, NSError?) -> Void`
	
	*/
	public class func listAircraft(handler: AirMapAircraftCollectionHandler) {
		pilotClient.listAircraft().subscribe(handler)
	}
	
	/**
	
	Create a new aircraft for the authenticated user
	
	- parameter pilot: `AirMapPilot`
	- parameter aircraft: The `AirMapAircarft` to create
	- parameter handler: `(AirMapAircraft?, NSError?) -> Void`
	
	*/
	public class func createAircraft(aircraft: AirMapAircraft, handler: AirMapAircraftHandler) {
		pilotClient.createAircraft(aircraft).subscribe(handler)
	}
	
	/**
	
	Update an aircraft for the authenticated user
	
	- parameter aircraft: The `AirMapAircarft` to update
	- parameter handler: `(AirMapAircraft?, NSError?) -> Void`
	
	*/
	public class func updateAircraft(aircraft: AirMapAircraft, handler: AirMapAircraftHandler) {
		pilotClient.updateAircraft(aircraft).subscribe(handler)
	}
	
	/**
	
	Delete an aircraft
	
	- parameter aircraft: The `AirMapAircarft` to update
	- parameter handler: `(NSError?) -> Void`
	
	*/
	public class func deleteAircraft(aircraft: AirMapAircraft, handler: AirMapErrorHandler) {
		pilotClient.deleteAircraft(aircraft).subscribe(handler)
	}
	
}
