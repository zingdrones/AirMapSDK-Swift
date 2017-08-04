//
//  AirMapStatusAdvisoryEmergencyProperties.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/27/17.
//

import ObjectMapper

open class AirMapStatusAdvisoryEmergencyProperties: AdvisoryProperties {
	
	open var dateEffective: Date?
	open var type: String?
	
	public required init?(map: Map) {}
}

extension AirMapStatusAdvisoryEmergencyProperties: Mappable {
	
	public func mapping(map: Map) {
		dateEffective <- (map["date_effective"], ISO8601DateTransform())
		type <- map["type"]
	}
}
