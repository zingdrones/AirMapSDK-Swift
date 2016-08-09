//
//  AirMapStatusAdvisorySpecialUseAirspaceProperties.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/8/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

@objc public class AirMapStatusAdvisoryWildfireProperties: NSObject {

	public var size: Int?
	public var dateEffective: NSDate?

	public required init?(_ map: Map) {}
}

extension AirMapStatusAdvisoryWildfireProperties: Mappable {

	public func mapping(map: Map) {
		
		"2016-06-30T16:54:17.606Z"
		
		let dateTransform = CustomDateFormatTransform(formatString: Config.AirMapApi.dateFormat)

		size			<- map["size"]
		dateEffective	<- (map["date_effective"], dateTransform)
	}
}
