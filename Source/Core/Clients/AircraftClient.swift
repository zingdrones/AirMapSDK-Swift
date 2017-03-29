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
		super.init(basePath: Config.AirMapApi.aircraftUrl)
	}
	
	func listManufacturers() -> Observable<[AirMapAircraftManufacturer]> {
		AirMap.logger.debug("Get Aircraft Manufacturers")
		return perform(method: .get, path: "/manufacturer")
	}
	
	func listModels() -> Observable<[AirMapAircraftModel]> {
		AirMap.logger.debug("Get Aircraft Models")
		return perform(method: .get, path: "/model")
	}
	
	func getModel(_ modelId: String) -> Observable<AirMapAircraftModel> {
		AirMap.logger.debug("Get Model", modelId)
		return perform(method: .get, path: "/model/\(modelId)")
	}
}
