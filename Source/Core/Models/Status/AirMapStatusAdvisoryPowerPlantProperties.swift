//
//  AirMapStatusAdvisoryPowerPlantProperties.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/11/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

@objc public class AirMapStatusAdvisoryPowerPlantProperties: NSObject {

	public var generatorType: String?
	public var output: Int?

	public required init?(_ map: Map) {}
}

extension AirMapStatusAdvisoryPowerPlantProperties: Mappable {

	public func mapping(map: Map) {
		generatorType		<- map["generator_type"]
		output				<- map["output"]
	}
}
