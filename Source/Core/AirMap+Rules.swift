//
//  AirMap+Rules.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 1/11/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

private typealias AirMap_Rules = AirMap
extension AirMap_Rules {
	
	public typealias AirMapLocalRulesHandler = ([AirMapLocalRule]?, NSError?) -> Void
	
	/**
	
	Get the local jurisdiction(s) rules for a give location
	
	- parameter location: A coordinate to search for rules
	- parameter handler: `([AirMapLocalRule]?, NSError?) -> Void`
	
	*/
	public class func getLocalRules(location: CLLocationCoordinate2D, handler: AirMapLocalRulesHandler) {
		
		rulesClient.getLocalRules(location).subscribe(handler)
	}

}
