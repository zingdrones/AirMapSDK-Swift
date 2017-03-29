//
//  StatusAdvisoriesTests.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

@testable import AirMap
import Nimble
import RxSwift

class StatusAdvisoriesTests: TestCase {

	func testGetStatusAdvisories() {

		stub(.get, Config.AirMapApi.statusUrl + "/point", with: "status_advisories_success.json")

		waitUntil { done in

			let whiteHouse = CoordinateFactory.whiteHouseCoordinate()
			AirMap.rx.checkCoordinate(coordinate: whiteHouse, buffer: 500)
				.subscribe(
					onNext: { status in
						
						guard let advisory = status.advisories.first else {
							expect(status.advisories.first).toNot(beNil()); return
						}
						expect(advisory.id).to(equal("bea6f3a8-8d04-48e5-8ed2-96b5c459b1fc"))
						expect(advisory.name).to(equal("P56A (DISTRICT OF COLUMBIA)"))
						expect(advisory.type).to(equal(AirMapAirspaceType.specialUse))
						expect(advisory.color).to(equal(AirMapStatus.StatusColor.red))
						expect(advisory.distance).to(equal(0))
						expect(advisory.latitude).to(equal(38.8944444))
						expect(advisory.longitude).to(equal(-77.0276391))
						expect(advisory.country).to(equal("USA"))
						expect(advisory.state).to(equal("District of Columbia"))
						expect(advisory.city).to(equal("Washington"))
				},
					onError: { error in
						expect(error).to(beNil())
				},
					onCompleted: done )
				.disposed(by: self.disposeBag)
		}

	}
}
