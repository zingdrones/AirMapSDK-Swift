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
	
	public static func listAdvisories(geometry: [Coordinate2D], ruleSets: [AirMapRuleSet]? = [], completion: @escaping (Result<[AirMapAdvisory]>) -> Void) {
		advisoryClient.listAdvisories(within: geometry, under: ruleSets).subscribe(completion)
	}
	
}
