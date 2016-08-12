//
//  AirMap+Flights.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/28/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

private typealias AirMap_Permits = AirMap
extension AirMap_Permits {

	public typealias AirMapPermitResponseHandler = (AirMapPilotPermit?, NSError?) -> Void
	public typealias AirMapAvailablePermitResponseHandler = (AirMapAvailablePermit?, NSError?) -> Void
	public typealias AirMapPermitCollectionResponseHandler = ([AirMapAvailablePermit]?, NSError?) -> Void

	/**

	Returns a list of `AirMapAvailablePermit`'s based upon a permit id or organization id.

	- parameter permitId: Optional permit identifier
	- parameter orgainizationId: Optional organization identifier
	- parameter handler: `([AirMapAvailablePermit]?, NSError?) -> Void`

	*/
	public class func listPermits(permitIds: [String]? = nil, organizationId: String? = nil, handler: AirMapPermitCollectionResponseHandler) {
		permitClient.list(permitIds, organizationId: organizationId).subscribe(handler)
	}

	/**
	
	Returns a of `AirMapAvailablePermit`'s based upon a permitId or orgainizationId.

	- parameter permitId: Optional permit identifier
	- parameter orgainizationId: Optional orgainization identifier
	- parameter handler: `([AirMapOrganizationPermit]?, NSError?) -> Void`

	*/
	public class func getAvailablePermit(permitId: String, handler: AirMapAvailablePermitResponseHandler) {
		return permitClient.list([permitId]).map { $0.first }.subscribe(handler)
	}

	/**
	
	Applies for an `AirMapPermit`

	- parameter handler: `(AirMapPilotPermit?, NSError?) -> Void`

	*/
	public class func applyForPermit(permit: AirMapAvailablePermit, handler: AirMapPermitResponseHandler) {
		permitClient.apply(permit).subscribe(handler)
	}

}
