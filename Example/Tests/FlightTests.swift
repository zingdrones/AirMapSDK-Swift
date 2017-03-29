//
//  AirMapSDKTests.swift
//  AirMapSDKTests
//
//  Created by Adolfo Martinelli on 7/1/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

@testable import AirMap
import Nimble
import RxSwift

class FlightTests: TestCase {

	func testCreateFlight() {

		let flight = FlightFactory.defaultFlight()
		
		stub(.post, Config.AirMapApi.flightUrl + "/point", with: "flight_post_success.json") { request in
			let json = request.bodyJson()
			expect(json["latitude"] as? Double).to(equal(flight.coordinate.latitude))
			expect(json["longitude"] as? Double).to(equal(flight.coordinate.longitude))
			expect(json["max_altitude"] as? Double).to(equal(flight.maxAltitude))
			expect(json["aircraft_id"] as? String).to(equal(flight.aircraftId))
			expect(json["public"] as? Bool).to(equal(false))
			expect(json["notify"] as? Bool).to(equal(true))
			expect(json["buffer"] as? Double).to(equal(flight.buffer))
			expect(json["start_time"] as? String).to(equal(flight.startTime?.ISO8601String()))
			expect(json["end_time"] as? String).to(equal(flight.endTime?.ISO8601String()))
			
			// TODO: Add tests for flight geometry, permits, and statuses
		}
		
		waitUntil { done in
			AirMap.rx.createFlight(flight)
				.subscribe(
					onNext: { newFlight in
						let refFlight = FlightFactory.defaultFlight()
						expect(newFlight).to(beIdenticalTo(flight))
						expect(newFlight.flightId).to(equal(refFlight.flightId))
						expect(newFlight.coordinate).to(equal(refFlight.coordinate))
						expect(newFlight.maxAltitude).to(equal(refFlight.maxAltitude))
						expect(newFlight.startTime?.timeIntervalSinceReferenceDate)
							.to(beCloseTo(refFlight.startTime?.timeIntervalSinceReferenceDate ?? 0, within: 0.001))
						expect(newFlight.endTime?.timeIntervalSinceReferenceDate)
							.to(beCloseTo(refFlight.endTime?.timeIntervalSinceReferenceDate ?? 0, within: 0.001))
						expect(newFlight.buffer).to(equal(refFlight.buffer))
						expect(newFlight.notify).to(equal(refFlight.notify))
						expect(newFlight.isPublic).to(equal(refFlight.isPublic))
						expect(newFlight.pilotId).to(equal(refFlight.pilotId)) },
					onError: {
						expect($0).to(beNil()); done() },
					onCompleted: done
				)
				.disposed(by: self.disposeBag)
		}
	}

	func testGetCurrentFlight() {

		stub(.get, Config.AirMapApi.flightUrl, with: "flight_get_success.json")

		waitUntil { done in
			AirMap.rx.getCurrentAuthenticatedPilotFlight()
				.subscribe(
					onNext: { currentFlight in
						expect(currentFlight).toNot(beNil())
						expect(currentFlight?.aircraftId).to(equal("aircraft|1234")) },
					onError: {
						expect($0).to(beNil()); done() },
					onCompleted: done
				)
				.disposed(by: self.disposeBag)
		}
	}

	func testGetCurrentFlightNoFlight() {

		stub(.get, Config.AirMapApi.flightUrl, with: "empty_flights_success.json")

		waitUntil { done in
			AirMap.rx.getCurrentAuthenticatedPilotFlight()
				.subscribe(
					onNext: { currentFlight in
						expect(currentFlight).to(beNil()) },
					onError: {
						expect($0).to(beNil()); done() },
					onCompleted: done
				)
				.disposed(by: self.disposeBag)
		}
	}

	func testListAllFlights() {

		stub(.get, Config.AirMapApi.flightUrl, with: "flights_get_success.json")
		
		waitUntil { done in
			AirMap.rx.listPublicFlights()
				.subscribe(
					onNext: { allFlights in
						expect(allFlights).toNot(beNil()) },
					onError: {
						expect($0).to(beNil()); done() },
					onCompleted: done
				)
				.disposed(by: self.disposeBag)
		}
	}

	func testDeleteFlight() {

		let flight = FlightFactory.defaultFlight()

		stub(.delete, Config.AirMapApi.flightUrl + "/\(flight.flightId!)", with: "empty_success.json")

		waitUntil { done in
			AirMap.rx.deleteFlight(flight)
				.subscribe(
					onError: { expect($0).to(beNil()); done() },
					onCompleted: done
				)
				.disposed(by: self.disposeBag)
		}
	}

	func testGetCommKey() {

		let flight = FlightFactory.defaultFlight()
		let url = Config.AirMapApi.flightUrl + "/\(flight.flightId!)/start-comm"

		stub(.post, url, with: "flight_comm_key_success.json") { request in
			expect(request.bodyJson().keys.count).to(equal(0))
		}

		waitUntil { done in
			AirMap.flightClient.getCommKey(flight: flight)
				.subscribe(
					onNext: { comm in
						expect(comm.key).to(equal("00001111222233334444555566667777")) },
					onError: { expect($0).to(beNil()); done() },
					onCompleted: done
				)
				.disposed(by: self.disposeBag)
		}
	}

}
