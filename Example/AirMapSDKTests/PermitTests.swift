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

class PermitTests: TestCase {

	let disposeBag = DisposeBag()


	func testGetSinglePermit() {

		stub(.GET, "/permit/\(AirMap.env())", with: "permit_get_success.json")

		let permitId = "permit|abc123"

		waitUntil { done in
			AirMap.rx_getAvailablePermit(permitId)
				.doOnNext { permit in
					expect(permit).toNot(beNil())
					expect(permit?.id).to(equal(permitId))
				}
				.doOnError { expect($0).to(beNil()); done() }
				.doOnCompleted(done)
				.subscribe()
				.addDisposableTo(self.disposeBag)
		}

	}

	func testApplyForPermit() {

		let permit = AirMapAvailablePermit()
		permit.id = "permit|abc123"
		
		let studentId = AirMapPilotPermitCustomProperty()
		studentId.id = "student_id"
		studentId.value = "UW2345aw"
		studentId.label = "Student ID number"
		
		permit.customProperties = [studentId]

		stub(.POST, "/permit/\(AirMap.env())/\(permit.id)/apply", with: "permit_apply_success.json")

		waitUntil { done in
			AirMap.rx_applyForPermit(permit)
				.doOnNext { appliedPermit in
					expect(appliedPermit).toNot(beNil())
					expect(appliedPermit.permitId).to(equal("permit|abc123"))
					expect(appliedPermit.status).to(equal(AirMapPilotPermit.PermitStatus.Pending))
					expect(appliedPermit.customProperties.count).to(equal(permit.customProperties.count))
				}
				.doOnError { error in
					expect(error).to(beNil())
				}
				.doOnCompleted(done)
				.subscribe()
				.addDisposableTo(self.disposeBag)
		}
	}

}
