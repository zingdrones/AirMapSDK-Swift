//
//  AirMapAirspaceAdvisoryStatus.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 4/10/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class AirMapAirspaceAdvisoryStatus: Mappable {

	public let color: AirMapStatus.StatusColor
	public let advisories: [AirMapAdvisory]
	
	public required init?(map: Map) {
		
		do {
			color        = try map.value("advisory_color")
			advisories   = try map.value("advisories")
		}
			
		catch let error {
			print(error)
			return nil
		}
	}
	
	public func mapping(map: Map) {}
}
