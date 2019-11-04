////
////  AircraftTests.swift
////  AirMapSDK
////
////  Created by Adolfo Martinelli on 7/18/16.
////  Copyright © 2016 AirMap, Inc. All rights reserved.
////
//
//@testable import AirMap
//import Nimble
//import RxSwift
//
//class AircraftTests: TestCase {
//
//	func testCreateAircraft() {
//
//		let aircraft = AircraftFactory.defaultAircraft()
//
//		stub(.post, Config.AirMapApi.pilotUrl + "/1234/aircraft", with: "pilot_aircraft_create_success.json") { request in
//			let json = request.bodyJson()
//			expect(json.keys.count).to(equal(2))
//			expect(json["model_id"] as? String).to(equal(aircraft.model.modelId))
//			expect(json["nickname"] as? String).to(equal(aircraft.nickname))
//		}
//
//		waitUntil { done in
//			AirMap.rx.createAircraft(aircraft)
//				.subscribe(
//					onNext: { aircraft in
//						let ref = AircraftFactory.defaultAircraft()
//						expect(aircraft.nickname).to(equal(ref.nickname))
//						expect(aircraft.aircraftId).to(equal(ref.aircraftId))
//						expect(aircraft.model.name).to(equal(ref.model.name))
//						expect(aircraft.model.modelId).to(equal(ref.model.modelId))
//						expect(aircraft.model.manufacturer.name).to(equal(ref.model.manufacturer.name))
//						expect(aircraft.model.manufacturer.id).to(equal(ref.model.manufacturer.id)) },
//					onError: { error in
//						expect(error).to(beNil()); done() },
//					onCompleted: done
//				)
//				.disposed(by: self.disposeBag)
//		}
//	}
//
//	func testListAircraftManufacturers() {
//
//		stub(.get, Config.AirMapApi.aircraftUrl + "/manufacturer", with: "aircraft_manufacturers_success.json")
//
//		waitUntil { done in
//			AirMap.rx.listManufacturers()
//				.subscribe(
//					onNext: { manufacturers in
//						let refManufacturer = AircraftFactory.defaultAircraft().model.manufacturer
//						expect(manufacturers.count).to(equal(2))
//						expect(manufacturers.first?.name).to(equal(refManufacturer?.name))
//						expect(manufacturers.first?.id).to(equal(refManufacturer?.id)) },
//					onError: { error in
//						expect(error).to(beNil()); done() },
//					onCompleted: done
//				)
//				.disposed(by: self.disposeBag)
//		}
//	}
//
//	func testListAircraftModels() {
//
//		stub(.get, Config.AirMapApi.aircraftUrl + "/model", with: "aircraft_models_success.json")
//
//		waitUntil { done in
//			AirMap.rx.listModels()
//				.subscribe(
//					onNext: { models in
//						let ref = AircraftFactory.defaultAircraft()
//						expect(models.count).to(equal(2))
//						expect(models.first?.modelId).to(equal(ref.model.modelId))
//						expect(models.first?.name).to(equal(ref.model.name))
//						expect(models.first?.manufacturer).toNot(beNil())
//						expect(models.first?.manufacturer.name).to(equal(ref.model.manufacturer.name))
//						expect(models.first?.manufacturer.id).to(equal(ref.model.manufacturer.id)) },
//					onError: { error in
//						expect(error).to(beNil()); done() },
//					onCompleted: done
//				)
//				.disposed(by: self.disposeBag)
//		}
//	}
//
//	func testGetAircraftModel() {
//		
//		stub(.get, Config.AirMapApi.aircraftUrl + "/model/1234", with: "aircraft_model_success.json")
//
//		waitUntil { done in
//			AirMap.rx.getModel("1234")
//				.subscribe(
//					onNext: { model in
//						let ref = AircraftFactory.defaultAircraft()
//						expect(model).toNot(beNil())
//						expect(model.modelId).to(equal(ref.model.modelId))
//						expect(model.name).to(equal(ref.model.name))
//						expect(model.manufacturer).toNot(beNil())
//						expect(model.manufacturer.id).to(equal(ref.model.manufacturer.id))
//						expect(model.manufacturer.name).to(equal(ref.model.manufacturer.name))
//						expect(model.metadata["flight_time"] as? Int).to(equal(20))
//						expect(model.metadata["image"] as? String).to(equal("http://cdn.airmap.io/acme-superdrone5000.jpg")) },
//					onError: { error in
//						expect(error).to(beNil()); done() },
//					onCompleted: done
//				)
//				.disposed(by: self.disposeBag)
//		}
//
//	}
//
//}
