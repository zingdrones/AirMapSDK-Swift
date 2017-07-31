//
//  AirMapStatusAdvisoryFireProperties.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/27/17.
//

import Foundation

import ObjectMapper

open class AirMapStatusAdvisoryFireProperties: AdvisoryProperties {
	
	open var dateEffective: Date?
	
	public required init?(map: Map) {}
}

extension AirMapStatusAdvisoryFireProperties: Mappable {
	
	public func mapping(map: Map) {
		dateEffective <- (map["date_effective"], ISO8601DateTransform())
	}
}
