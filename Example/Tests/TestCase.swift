//
//  TestCase.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/1/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import XCTest
import OHHTTPStubs
import Alamofire

@testable import AirMap

class TestCase: XCTestCase {
	
	enum HTTPMethod {
		case GET, POST, PUT, PATCH, DELETE
	}
	
	override func setUp() {
		super.setUp()

		AirMap.authToken = "abcd"
		AirMap.authSession.userId = "1234"
		AirMap.authSession.expiresAt = .distantFuture()
	}
	
	func stub(method: HTTPMethod, _ uri: String, with fixture: String, onRequest: ((NSURLRequest) -> Void)? = nil) {
		
		let requestTest = { (request: NSURLRequest) -> Bool in
			let url = NSURL(string: uri.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!
			return request.HTTPMethod == String(method)
				&& request.URL?.host == url.host
				&& request.URL?.path == url.path
		}
		
		let responseBlock = { (request: NSURLRequest) -> OHHTTPStubsResponse in
			let bundle = NSBundle(forClass: self.dynamicType)
			let path = bundle.pathForResource(fixture, ofType: nil)!
			return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: ["Content-Type":"application/json"])
		}
		
		OHHTTPStubs.stubRequestsPassingTest(requestTest, withStubResponse: responseBlock)
		OHHTTPStubs.onStubActivation { request, descriptor, response in
			onRequest?(request)
		}
	}
	
}

extension NSURLRequest {
	
	func bodyJson() -> [String: AnyObject] {
		
		if let requestBody = OHHTTPStubs_HTTPBody(), json = try? NSJSONSerialization.JSONObjectWithData(requestBody, options: .AllowFragments) as? [String: AnyObject] {
			return json ?? [:]
		} else {
			return [:]
		}
	}
	
	func queryParams() -> [String: AnyObject] {
		
		guard let components = NSURLComponents(URL: URL!, resolvingAgainstBaseURL: false) else {
			return [:]
		}
		
		let items = components.queryItems ?? []
		let query = items.reduce([:], combine: { ( dict: [String: AnyObject], item: NSURLQueryItem) -> [String: AnyObject] in
			var dict = dict
			dict[item.name] = item.value
			return dict
		})
		return query
	}
}
