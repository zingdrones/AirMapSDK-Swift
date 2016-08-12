//
//  AircraftClient.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/21/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift

internal class AircraftClient: HTTPClient {
	
	init() {
		super.init(Config.AirMapApi.aircraftUrl)
	}
	
	func listManufacturers() -> Observable<[AirMapAircraftManufacturer]> {
		AirMap.logger.debug("Get Aircraft Manufacturers")
		return call(.GET, url:"/manufacturer")
	}
	
	func listModels() -> Observable<[AirMapAircraftModel]> {
		AirMap.logger.debug("Get Aircraft Models")
		return call(.GET, url:"/model")
	}
	
	func getModel(modelId: String) -> Observable<AirMapAircraftModel> {
		AirMap.logger.debug("Get Model", modelId)
		return call(.GET, url:"/model/\(modelId.urlEncoded)")
	}
}
