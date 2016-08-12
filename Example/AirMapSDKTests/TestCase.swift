//
//  TestCase.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/1/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Mockingjay
import XCTest
@testable import AirMap

class TestCase: XCTestCase {

	func setup() {
		super.setUp()

		AirMap.authToken = nil
		XCTAssert(AirMap.authSession.hasValidCredentials())
	}

	func stub(method: HTTPMethod, _ uri: String, with fixtureNamed: String) {
		stub(http(method, uri: uri), builder: fixture(fixtureNamed))
	}

	func fixture(named: String, status: Int = 200, headers: [String: String]? = nil) -> Builder {
		return { (request: NSURLRequest) in
			let bundle = NSBundle(forClass: self.dynamicType)
			let path = bundle.pathForResource(named, ofType: nil)!
			let data = NSData(contentsOfFile: path)!
			return jsonData(data, status: status)(request: request)
		}
	}
}
