//
//  AirMapFlight+NotificationStatus.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/7/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public enum AirMapFlightStatusType: String {

	case accepted
	case rejected
	case pending
	case unknown
}

open class AirMapFlightStatus {

	open var id: String!
	open var managerId: String!
	open var status: AirMapFlightStatusType = .unknown

	public required init?(map: Map) {}

}

extension AirMapFlightStatus: Mappable {

	public func mapping(map: Map) {

		id        <- map["id"]
		managerId <- map["manager_id"]

		var statusType = "unknown"
		statusType  <- map["status"]
		status = AirMapFlightStatusType(rawValue: statusType) ?? .unknown
	}

}
