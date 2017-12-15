//
//  AircraftClient.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/21/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation
import RxSwift

internal class AircraftClient: HTTPClient {
	
	init() {
		super.init(basePath: Constants.AirMapApi.aircraftUrl)
	}
	
	func listManufacturers() -> Observable<[AirMapAircraftManufacturer]> {
		AirMap.logger.debug("Get Aircraft Manufacturers")
		return perform(method: .get, path: "/manufacturer")
	}
	
	func searchManufacturers(by name: String) -> Observable<[AirMapAircraftManufacturer]> {
		AirMap.logger.debug("Search Aircraft Manufacturers by Name", name)
		return perform(method: .get, path: "/manufacturer", params: ["q": name])
	}

	func listModels(by manufacturerId: AirMapAircraftManufacturerId) -> Observable<[AirMapAircraftModel]> {
		AirMap.logger.debug("Get Manufacturer Models", manufacturerId)
		return perform(method: .get, path: "/model", params: ["manufacturer": manufacturerId])
	}

	func searchModels(by name: String) -> Observable<[AirMapAircraftModel]> {
		AirMap.logger.debug("Search Aircraft Models by Name", name)
		return perform(method: .get, path: "/model", params: ["q": name])
	}

	func getModel(_ modelId: AirMapAircraftModelId) -> Observable<AirMapAircraftModel> {
		AirMap.logger.debug("Get Model", modelId)
		return perform(method: .get, path: "/model/\(modelId)")
	}
}
