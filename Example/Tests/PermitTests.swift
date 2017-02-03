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

class PermitTests: TestCase {

	func testGetSinglePermit() {

		stub(.get, Config.AirMapApi.permitUrl, with: "permit_get_success.json")

		let permitId = "permit|1234"

		waitUntil { done in
			AirMap.rx.getAvailablePermit(permitId)
				.subscribe(
					onNext: { permit in
						expect(permit).toNot(beNil())
						expect(permit?.id).to(equal(permitId))
						expect(permit?.organizationId).to(equal("organization|1234"))
						expect(permit?.info).to(equal("A permit for recreational operators"))
						expect(permit?.singleUse).to(equal(false))
						expect(permit?.validUntil).to(equal(Date.dateFromISO8601String("2017-01-01T00:00:00.000Z")))
						expect(permit?.customProperties.count).to(equal(1))
						let customProperty = permit?.customProperties.first
						expect(customProperty?.id).to(equal("permit_custom_property|1234"))
						expect(customProperty?.type).to(equal("text"))
						expect(customProperty?.label).to(equal("Name"))
						expect(customProperty?.required).to(equal(false)) },
					onError: { expect($0).to(beNil()); done() },
					onCompleted: done )
				.addDisposableTo(self.disposeBag)
		}
	}

	func testApplyForPermit() {

		let permit = AirMapAvailablePermit()
		permit.id = "permit|1234"
		
		let customProperty = AirMapPilotPermitCustomProperty()
		customProperty.id = "permit_custom_property|1234"
		customProperty.value = "12345678"
		customProperty.label = "Student ID number"
		
		permit.customProperties = [customProperty]

		let url = Config.AirMapApi.permitUrl + "/\(permit.id)/apply"
		stub(.post, url, with: "permit_apply_success.json") { request in

			let json = request.bodyJson()
			expect(json["id"] as? String).to(equal(permit.id))
			let customProperties = json["custom_properties"] as? [[String: String]]
			let property = customProperties?.first
			expect(property?["id"]).to(equal("permit_custom_property|1234"))
			expect(property?["value"]).to(equal("12345678"))
		}

		waitUntil { done in
			AirMap.rx.apply(for: permit)
				.subscribe(
					onNext: { appliedPermit in
						expect(appliedPermit).toNot(beNil())
						expect(appliedPermit.permitId).to(equal("permit|1234"))
						expect(appliedPermit.status).to(equal(AirMapPilotPermit.PermitStatus.pending))
						expect(appliedPermit.customProperties.count).to(equal(permit.customProperties.count)) },
					onError: { error in
						expect(error).to(beNil()) },
					onCompleted: done )
				.addDisposableTo(self.disposeBag)
		}
	}

}
