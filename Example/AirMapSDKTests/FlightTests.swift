//
//  AirMapSDKTests.swift
//  AirMapSDKTests
//
//  Created by Adolfo Martinelli on 7/1/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

@testable import AirMap
import Nimble
import Mockingjay
import RxSwift

class FlightTests: TestCase {

	let disposeBag = DisposeBag()

	func testCreateFlight() {

		let coordinate = CLLocationCoordinate2D(latitude: 33.123456, longitude: 110.123456)
		let startTime = NSDate.dateFromISO8601String("2016-07-01T22:32:11.123Z")
		let isPublic = false
		let maxAltitude = 100.0
		let buffer = 100.0
		let notify = true

		let flight = AirMapFlight()
		flight.coordinate = coordinate
		flight.startTime = startTime
		flight.isPublic = isPublic
		flight.maxAltitude = maxAltitude
		flight.buffer = buffer
		flight.notify = notify
		let point = AirMapPoint()
		point.coordinate = coordinate


		stub(.POST, "/flight/\(AirMap.env())/point", with: "flight_post_success.json")

		waitUntil { done in
			AirMap.rx_createFlight(flight)
				.doOnNext { newFlight in
					expect(newFlight).to(beIdenticalTo(flight))
					expect(newFlight.flightId).to(equal("468b63fa-820d-4e9e-9ffe-c0b6b91e654b"))
					expect(newFlight.coordinate.latitude).to(equal(coordinate.latitude))
					expect(newFlight.coordinate.longitude).to(equal(coordinate.longitude))
					expect(newFlight.maxAltitude).to(equal(maxAltitude))
					expect(newFlight.startTime?.timeIntervalSinceReferenceDate)
						.to(beCloseTo(startTime.timeIntervalSinceReferenceDate, within: 0.001))
					expect(newFlight.buffer).to(equal(buffer))
					expect(newFlight.notify).to(equal(notify))
					expect(newFlight.isPublic).to(equal(isPublic))
				}
				.doOnError { expect($0).to(beNil()); done() }
				.doOnCompleted(done)
				.subscribe()
				.addDisposableTo(self.disposeBag)
		}
	}

	func testGetCurrentFlight() {

		stub(.GET, "/flight/\(AirMap.env())", with: "flight_get_success.json")

		waitUntil { done in
			AirMap.rx_getCurrentAuthenticatedPilotFlight()
				.doOnNext { currentFlight in
					expect(currentFlight).toNot(beNil())
				}
				.doOnError { expect($0).to(beNil()); done() }
				.doOnCompleted(done)
				.subscribe()
				.addDisposableTo(self.disposeBag)
		}

	}

	func testGetCurrentFlightNoFlight() {

		stub(.GET, "/flight/\(AirMap.env())", with: "empty_flights_success.json")

		waitUntil { done in
			AirMap.rx_getCurrentAuthenticatedPilotFlight()
				.doOnNext { currentFlight in
					expect(currentFlight).to(beNil())
				}
				.doOnError { expect($0).to(beNil()); done() }
				.doOnCompleted(done)
				.subscribe()
				.addDisposableTo(self.disposeBag)
		}
	}

	func testListAllFlights() {

		stub(.GET, "/flight/\(AirMap.env())", with: "flights_get_success.json")

		waitUntil { done in
			AirMap.rx_listAllPublicAndAuthenticatedPilotFlights()
				.doOnNext { allFlights in
					expect(allFlights).toNot(beNil())
				}
				.doOnError { expect($0).to(beNil()); done() }
				.doOnCompleted(done)
				.subscribe()
				.addDisposableTo(self.disposeBag)
		}
	}

	func testDeleteFlight() {

		let flight = FlightFactory.defaultFlight()

		stub(.DELETE, "/flight/\(AirMap.env())/\(flight.flightId)", with: "empty_success.json")

		waitUntil { done in
			AirMap.rx_deleteFlight(flight)
				.doOnError { expect($0).to(beNil()); done() }
				.doOnCompleted(done)
				.subscribe()
				.addDisposableTo(self.disposeBag)
		}
	}

	func testGetCommKey() {

		let flight = FlightFactory.defaultFlight()

		stub(.PATCH, "/flight/\(AirMap.env())/\(flight.flightId)/start-comm", with: "flight_comm_key_success.json")

		waitUntil { done in
			AirMap.flightClient.getCommKey(flight)
				.doOnNext { comm in
					expect(comm.type).to(equal("Buffer"))
					expect(comm.key).to(equal([201, 49, 58, 234, 67, 135, 252, 215, 251, 132, 90, 119, 192, 127, 77, 39,
						234, 70, 138, 229, 75, 193, 234, 177, 147, 236, 126, 245, 219, 47, 242, 86]))
				}
				.doOnError { expect($0).to(beNil()); done() }
				.doOnCompleted(done)
				.subscribe()
				.addDisposableTo(self.disposeBag)
		}
	}

}
