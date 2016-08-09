//
//  AirMapStatus.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

@objc public class AirMapStatus: NSObject {

	public enum StatusColor: String {
		case Red    = "red"
		case Yellow = "yellow"
		case Green  = "green"
		case Gray   = "gray"
	}

	public var maxSafeDistance = 0
	public var advisoryColor = StatusColor.Gray
	public var advisories = [AirMapStatusAdvisory]()
	public var weather: AirMapStatusWeather?

	public required init(_ map: Map) {}

	public var numberOfRequiredPermits: Int {
		return advisories
			.map { $0.requirements?.permitsAvailable ?? [] }
			.flatMap { $0 }
			.count
	}

	public var numberOfNoticesRequired: Int {
		return advisories
			.map { $0.requirements?.notice }
			.flatMap { $0 }
			.count
	}

}

extension AirMapStatus: Mappable {

	public func mapping(map: Map) {
		maxSafeDistance <- map["max_safe_distance"]
		advisories      <- map["advisories"]
		weather         <- map["weather"]
		advisoryColor   <- map["advisory_color"]
	}
}
