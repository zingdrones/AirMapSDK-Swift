//
//  AirMapStatusAdvisoryPowerPlantProperties.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/11/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

@objc public class AirMapStatusAdvisorySchoolProperties: NSObject {

	public var students: Int? // number of students

	public required init?(_ map: Map) {}
}

extension AirMapStatusAdvisorySchoolProperties: Mappable {

	public func mapping(map: Map) {
		students			<- map["students"]
	}
}
