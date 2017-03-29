//
//  AirMap+Rules.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 1/11/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation

public typealias AirMap_Rules = AirMap
extension AirMap_Rules {
	
	public typealias AirMapLocalRulesHandler = ([AirMapLocalRule]?, Error?) -> Void
	
	/// List the local jurisdiction rules applicable to a given location
	///
	/// - Parameters:
	///   - location: The coordinate for which to list rules
	///   - completion: A completion handler to call with the Result
	public static func listLocalRules(location: Coordinate2D, completion: @escaping (Result<[AirMapLocalRule]>) -> Void) {
		
		rulesClient.listLocalRules(at: location).subscribe(completion)
	}

}
