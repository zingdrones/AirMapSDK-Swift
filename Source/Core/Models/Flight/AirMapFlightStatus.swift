//
//  AirMapFlight+NotificationStatus.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/7/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public enum AirMapFlightStatusType: String {

	case Accepted = "accepted"
	case Rejected = "rejected"
	case Pending  = "pending"
	case Unknown  = "unknown"
}

@objc public class AirMapFlightStatus: NSObject {

	public var id: String!
	public var managerId: String!
	public var status: AirMapFlightStatusType = .Unknown

	public required init?(_ map: Map) {
		super.init()
	}

	internal override init() {
		super.init()
	}

}

extension AirMapFlightStatus: Mappable {

	public func mapping(map: Map) {

		id        <- map["id"]
		managerId <- map["manager_id"]

		var statusType = "unknown"
		statusType  <- map["status"]
		status = statusTypeForString(statusType)
	}

	func statusTypeForString(status: String) -> AirMapFlightStatusType {
		return AirMapFlightStatusType(rawValue: status) ?? .Unknown
	}

}
