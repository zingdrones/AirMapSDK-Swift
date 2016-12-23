//
//  StatusAdvisoriesTests.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import AirMap
import Nimble
import RxSwift

class StatusAdvisoriesTests: TestCase {

//	let disposeBag = DisposeBag()

//	func testGetStatusAdvisories() {
//
//		stub(.GET, "/data/next2/status/point", with: "status_advisories_success.json")
//
//		waitUntil { done in
//
//			AirMap.rx_checkCoordinate(CoordinateFactory.whiteHouseCoordinate(), radius: 500)
//				.doOnNext { status in
//
//					guard let advisory = status.advisories.first else {
//						expect(status.advisories.first).toNot(beNil()); return
//					}
//					expect(advisory.id).to(equal("cff59ee7-f460-478f-88a0-1e860b521d5b"))
//					expect(advisory.name).to(equal("San Jose International Airport"))
//					expect(advisory.type).to(equal(AirMapAirspaceType.Airport))
//					expect(advisory.color).to(equal(AirMapStatus.StatusColor.Red))
//					expect(advisory.distance).to(equal(1_000))
//					expect(advisory.latitude).to(equal(34.043277))
//					expect(advisory.longitude).to(equal(-118.4688775))
//					expect(advisory.country).to(equal("USA"))
//					expect(advisory.state).to(equal("CA"))
//					expect(advisory.city).to(equal("San Jose"))
//
//					guard let properties = advisory.airportProperties else {
//						expect(advisory.airportProperties).toNot(beNil()); return
//					}
//					expect(properties.phone).to(equal("+14082774705"))
////					expect(properties.paved).to(equal(true))
//					expect(properties.tower).to(equal(true))
//					expect(properties.longestRunway).to(equal(11_000))
//					expect(properties.elevation).to(equal(62))
//					expect(properties.publicUse).to(equal(true))
//					expect(properties.identifier).to(equal("KSMO"))
//
//					guard let requirements = advisory.requirements else {
//						expect(advisory.requirements).toNot(beNil()); return
//					}
//					let permits = requirements.permitsAvailable
//					expect(permits.count).to(equal(1))
//
//					guard let permit = permits.first else { return }
//					expect(permit.id).to(equal("permit|02efar1"))
//					expect(permit.name).to(equal("Recreational Permit"))
//					expect(permit.info).to(equal("Non-commercial drone flights."))
//
//					let flow = requirements.permitDecisionFlow
//					expect(flow.firstQuestionId).to(equal("question|abc000"))
//
//					guard flow.questions.count == 2 else {
//						expect(flow.questions.count).to(equal(2)); return
//					}
//					let question1 = flow.questions[0]
//					expect(question1.id).to(equal("question|abc000"))
//					expect(question1.text).to(equal("Are you flying recreationally?"))
//
//					guard let q1Answer1 = question1.answers[0] as AirMapAvailablePermitAnswer? else { return }
//					expect(q1Answer1.id).to(equal("answer|xyz100"))
//					expect(q1Answer1.text).to(equal("Yes"))
//					expect(q1Answer1.permitId).to(equal("permit|02efar1"))
//					expect(q1Answer1.nextQuestionId).to(beNil())
//
//					guard let q1Answer2 = question1.answers[1] as AirMapAvailablePermitAnswer? else { return }
//					expect(q1Answer2.nextQuestionId).to(equal("question|abc001"))
//					expect(q1Answer2.permitId).to(beNil())
//
//					let question2 = flow.questions[1]
//					guard let q2Answer2 = question2.answers[1] as AirMapAvailablePermitAnswer? else { return }
//					expect(q2Answer2.message).to(equal("Please contact the airport for special use requirements."))
//
//				}
//				.doOnError { error in
//					expect(error).to(beNil())
//				}
//				.doOnCompleted(done)
//				.subscribe()
//				.addDisposableTo(self.disposeBag)
//		}
//
//	}
}
