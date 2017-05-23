//
//  AirMap+Advisories.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 4/8/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation

public typealias AirMap_Advisories = AirMap
extension AirMap_Advisories {
	
	public static func getAirspaceStatus(geometry: AirMapGeometry, ruleSets: [AirMapRuleSet], completion: @escaping (Result<AirMapAirspaceAdvisoryStatus>) -> Void) {
		advisoryClient.getAirspaceStatus(within: geometry, under: ruleSets).subscribe(completion)
	}
	
}
