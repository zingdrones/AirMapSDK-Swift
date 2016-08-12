//
//  PilotTests.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/19/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import AirMap
import Mockingjay
import Nimble
import RxSwift

class PilotTests: TestCase {

	let disposeBag = DisposeBag()

	func testPilotNotFound() {

		let pilotId: String = "auth1|56c3a9171ab18142396182fc"

		//		stub(.GET, Config.AirMapApi.pilotUrl + "\(pilotId)", with: "pilot_authorized_get_success.json")

		waitUntil { done in

			AirMap.rx_getPilot(pilotId)
				.doOnNext { pilot in
					expect(pilot).to(beNil())
				}
				.doOnError { expect($0).to(beNil()); done() }
				.doOnCompleted(done)
				.subscribe()
				.addDisposableTo(self.disposeBag)
		}

	}

	func testGetAuthorizedPilot() {

		let pilotId: String = "auth0|56c3a9171ab18142396182fc"

//		stub(.GET, Config.AirMapApi.pilotUrl + "\(pilotId)", with: "pilot_authorized_get_success.json")

		waitUntil { done in

			AirMap.rx_getPilot(pilotId)
				.doOnNext { pilot in
					expect(pilot.pilotId).to(equal(pilotId))
					expect(pilot.phoneVerified).to(equal(false))
					expect(pilot.emailVerified).to(equal(true))

					guard let faaRegistartionNumber = pilot.appMetadata["faa_registration_number"] as? String else { return }
					expect(faaRegistartionNumber).to(equal("E126B2167999"))
				}
				.doOnError { expect($0).to(beNil()); done() }
				.doOnCompleted(done)
				.subscribe()
				.addDisposableTo(self.disposeBag)
		}
	}

	func testUpdateFaaRegistrationNumber() {


		let pilotId: String = "auth0|56c3a9171ab18142396182fc"

		//		stub(.GET, Config.AirMapApi.pilotUrl + "\(pilotId)", with: "pilot_authorized_get_success.json")

		waitUntil { done in

			AirMap.rx_getPilot(pilotId)
				.doOnNext { pilot in
					pilot.userMetadata["faa_registration_number"] = "E126B2167999"

					AirMap.rx_updatePilot(pilot)
						.doOnNext { pilot in
							expect(pilot).notTo(beNil())
						}
						.doOnError { expect($0).to(beNil()); done() }
						.doOnCompleted(done)
						.subscribe()
						.addDisposableTo(self.disposeBag)

				}
				.doOnError { expect($0).to(beNil()); done() }
				.subscribe()
				.addDisposableTo(self.disposeBag)
		}
	}

}
