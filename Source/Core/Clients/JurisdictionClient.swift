//
//  JurisdictionClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/5/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation
import RxSwift

internal class JurisdictionClient: HTTPClient {
	
	init() {
		super.init(basePath: Constants.AirMapApi.jurisdictionUrl)
	}
	
	enum JurisdictionClientError: Error {
		case invalidPolygon
	}
		
}
