////
////  TestCase.swift
////  AirMapSDK
////
////  Created by Adolfo Martinelli on 7/1/16.
////  Copyright © 2016 AirMap, Inc. All rights reserved.
////
//
//import XCTest
//import OHHTTPStubs
//import Alamofire
//import RxSwift
//
//@testable import AirMap
//
//class TestCase: XCTestCase {
//	
//	enum HTTPMethod {
//		case get, post, put, patch, delete
//	}
//	
//	let disposeBag = DisposeBag()
//
//	override func setUp() {
//		super.setUp()
//
//		AirMap.authToken = "abcd"
//		AirMap.authSession.userId = "1234"
//		AirMap.authSession.expiresAt = .distantFuture
//	}
//	
//	func stub(_ method: HTTPMethod, _ uri: String, with fixture: String, onRequest: ((URLRequest) -> Void)? = nil) {
//	
//		let requestTest = { (request: URLRequest) -> Bool in
//			let url = URL(string: uri.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
//			let doesMatch = request.httpMethod?.lowercased() == String(describing: method).lowercased()
//				&& request.url?.host == url.host
//				&& request.url?.path == url.path
//			return doesMatch
//		}
//		
//		let responseBlock = { (request: URLRequest) -> OHHTTPStubsResponse in
//			let bundle = Bundle(for: type(of: self))
//			let path = bundle.path(forResource: fixture, ofType: nil)!
//			return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: ["Content-Type":"application/json"])
//		}
//		
//		OHHTTPStubs.stubRequests(passingTest: requestTest, withStubResponse: responseBlock)
//		OHHTTPStubs.onStubActivation { request, descriptor, response in
//			onRequest?(request)
//		}
//	}
//}
//
//extension URLRequest {
//	
//	func bodyJson() -> [String: AnyObject] {
//		
//		let request = self as NSURLRequest
//		
//		if let requestBody = request.ohhttpStubs_HTTPBody(), let json = try? JSONSerialization.jsonObject(with: requestBody, options: .allowFragments) as? [String: AnyObject] {
//			return json ?? [:]
//		} else {
//			return [:]
//		}
//	}
//	
//	func queryParams() -> [String: AnyObject] {
//		
//		guard let components = URLComponents(url: url!, resolvingAgainstBaseURL: false) else {
//			return [:]
//		}
//		
//		let items = components.queryItems ?? []
//		let query = items.reduce([:], { ( dict: [String: AnyObject], item: URLQueryItem) -> [String: AnyObject] in
//			var dict = dict
//			dict[item.name] = item.value as AnyObject?
//			return dict
//		})
//		return query
//	}
//}
