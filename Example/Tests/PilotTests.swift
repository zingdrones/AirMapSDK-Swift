//
//  PilotTests.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/19/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

@testable import AirMap
import Nimble
import RxSwift

class PilotTests: TestCase {

	func testGetAuthorizedPilot() {

		let pilotId: String = "pilot|1234"

		stub(.get, Config.AirMapApi.pilotUrl + "/\(pilotId)", with: "pilot_authorized_get_success.json")

		waitUntil { done in

			AirMap.rx.getPilot(pilotId)
				.subscribe (
					onNext: { pilot in
						expect(pilot.pilotId).to(equal(pilotId))
						expect(pilot.firstName).to(equal("Davey"))
						expect(pilot.lastName).to(equal("Dronehead"))
						expect(pilot.username).to(equal("daveyd"))
						expect(pilot.email).to(equal("davey@airmap.com"))
						expect(pilot.phoneVerified).to(equal(true))
						expect(pilot.emailVerified).to(equal(false))
						expect(pilot.pictureUrl).to(equal("http://cdn.airmap.com/users/photo.jpg"))
						expect(pilot.phone).to(equal("+13105551212"))
						expect(pilot.appMetadata()["faa_registration_number"] as? String).to(equal("faa|1234"))
						expect(pilot.statistics.totalFlights).to(equal(10))
						expect(pilot.statistics.lastFlightTime).to(equal(Date.dateFromISO8601String("2016-07-05T10:51:19.000Z")))
						expect(pilot.statistics.totalAircraft).to(equal(2)) },
					onError: {
						expect($0).to(beNil()); done() },
					onCompleted: done
				)
				.addDisposableTo(self.disposeBag)
		}
	}
	
	func testUpdatePilot() {
		
		let pilot = AirMapPilot()
		pilot.pilotId = "pilot|1234"
		pilot.firstName = "Davey"
		pilot.lastName = "Dronehead"
		pilot.username = "daveyd"
		pilot.phone = "+13105551212"
		pilot.setAppMetadata(value: "appmetabar", forKey: "appmetafoo")
		
		stub(.patch, Config.AirMapApi.pilotUrl + "/\(pilot.pilotId)", with: "pilot_authorized_get_success.json") { request in
			let json = request.bodyJson()
			expect(json["first_name"] as? String).to(equal(pilot.firstName))
			expect(json["last_name"] as? String).to(equal(pilot.lastName))
			expect(json["username"] as? String).to(equal(pilot.username))
			expect(json["phone"] as? String).to(equal(pilot.phone))
			expect(json["app_metadata"]?["appmetafoo"] as? String).to(equal("appmetabar"))
		}
		
		waitUntil { done in
			
			AirMap.rx.updatePilot(pilot)
				.subscribe(
					onNext: { pilot in
						expect(pilot).toNot(beNil()) },
					onError: {
						expect($0).to(beNil()); done() },
					onCompleted: done
				)
				.addDisposableTo(self.disposeBag)
		}
	}
}
