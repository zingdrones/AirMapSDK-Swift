//
//  AircraftTests.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/18/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

@testable import AirMap
import Nimble
import Mockingjay
import RxSwift

class AircraftTests: TestCase {

	let disposeBag = DisposeBag()

	func testCreateAircraft() {

		let aircraftModel = AirMapAircraftModel()
		aircraftModel.modelId = "76d29840-1bc5-469c-ba92-3f637a100c1d"

		let aircraft = AirMapAircraft()
		aircraft.nickname = "My Drone"
		aircraft.model = aircraftModel

		stub(.POST, "/pilot/\(AirMap.env())/:id/aircraft", with: "pilot_aircraft_create_success.json")

		waitUntil { done in
			AirMap.rx_createAircraft(aircraft)
				.doOnNext { createdAircraft in
					expect(createdAircraft).toNot(beNil())
				}
				.doOnError { expect($0).to(beNil()); done() }
				.doOnCompleted(done)
				.subscribe()
				.addDisposableTo(self.disposeBag)
		}

	}

	func testListAircraftManufacturers() {

		stub(.POST, "/aircraft/\(AirMap.env())/manufacturer", with: "aircraft_manufacturers_success.json")

		waitUntil { done in
			AirMap.rx_listManufacturers()
				.doOnNext { manufacturers in
					expect(manufacturers).toNot(beNil())
				}
				.doOnError { expect($0).to(beNil()); done() }
				.doOnCompleted(done)
				.subscribe()
				.addDisposableTo(self.disposeBag)
		}
	}

	func testListAircraftManufacturer() {

		stub(.POST, "/aircraft/\(AirMap.env())/manufacturer/", with: "aircraft_manufacturers_success.json")

		waitUntil { done in
			AirMap.rx_listManufacturers()
				.doOnNext { manufacturers in
					expect(manufacturers).toNot(beNil())
				}
				.doOnError { expect($0).to(beNil()); done() }
				.doOnCompleted(done)
				.subscribe()
				.addDisposableTo(self.disposeBag)
		}
	}


	func testListAircraftModels() {

		stub(.POST, "/aircraft/\(AirMap.env())/model", with: "aircraft_models_success.json")

		waitUntil { done in
			AirMap.rx_listModels()
				.doOnNext { models in
					expect(models).toNot(beNil())
				}
				.doOnError { expect($0).to(beNil()); done() }
				.doOnCompleted(done)
				.subscribe()
				.addDisposableTo(self.disposeBag)
		}

	}

	func testGetAircraftModel() {

		let modelId = "76d29840-1bc5-469c-ba92-3f637a100c1d"

		stub(.POST, "/aircraft/\(AirMap.env())/model/\(modelId)", with: "aircraft_model_success.json")

		waitUntil { done in
			AirMap.rx_getModel(modelId)
				.doOnNext { model in
					expect(model).toNot(beNil())
					expect(model.modelId).to(equal(modelId))
				}
				.doOnError { expect($0).to(beNil()); done() }
				.doOnCompleted(done)
				.subscribe()
				.addDisposableTo(self.disposeBag)
		}

	}


}
