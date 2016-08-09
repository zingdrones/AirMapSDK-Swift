//
//  HTTPClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/28/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Alamofire
import ObjectMapper
import RxSwift

internal class HTTPClient {

	enum MimeType: String {
		case JSON = "application/json"
	}

	enum Header: String {
		case Accept        = "Accept"
		case Authorization = "Authorization"
		case CacheControl  = "Cache-Control"
		case XApiKey       = "X-API-Key"
	}

	private let baseUrl: String!
	private var headers: [String : String] {
		return [Header.Accept.rawValue: MimeType.JSON.rawValue,
		 Header.XApiKey.rawValue : AirMap.authSession.apiKey  ?? "Adolofoo",
		 Header.Authorization.rawValue : (AirMap.authSession.tokenType ?? "") +  " " + (AirMap.authSession.authToken ?? "")]
	}

	lazy var manager: Manager = {

		let serverTrustPolicies: [String: ServerTrustPolicy] = [
			"api.airmap.io": .PinCertificates(
				certificates: ServerTrustPolicy.certificatesInBundle(AirMapBundle.mainBundle()),
				validateCertificateChain: true,
				validateHost: true
			),
		]

		if AirMap.authSession.enableCertificatePinning {
			return Manager(serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
		}

		return Manager()

	}()

	init(_ baseUrl: String) {
		self.baseUrl = baseUrl
	}

	func call<T: Mappable>(method: Alamofire.Method, url: String = "", params: [String: AnyObject] = [:], keyPath: String? = "data", update object: T? = nil, authCheck: Bool = false) -> Observable<T> {

		return Observable.create { (observer: AnyObserver<T>) -> Disposable in

			if authCheck && !AirMap.hasValidCredentials() {
				observer.onError(AirMapErrorType.Unauthorized)
				return AnonymousDisposable {}
			}

			let encoding: ParameterEncoding = (method == .GET) ? .URL : .JSON

			let request = self.manager.request(method, self.baseUrl + url, parameters: params, encoding: encoding, headers: self.headers)
				.responseObject(keyPath: keyPath, mapToObject: object) { (response: Response<T, NSError>) in

					if let error = response.result.error {
						AirMap.logger.error(method, String(T), url, error)
						observer.onError(error)
					} else {
						AirMap.logger.debug(String(T), "response:", response.result.value!)
						observer.on(.Next(response.result.value!))
						observer.on(.Completed)
					}
			}
			return AnonymousDisposable {
				request.cancel()
			}
		}
	}

	func call<T: Mappable>(method: Alamofire.Method, url: String = "", params: [String: AnyObject] = [:], keyPath: String? = "data", update object: T? = nil, authCheck: Bool = false) -> Observable<T?> {

		return Observable.create { (observer: AnyObserver<T?>) -> Disposable in
			if authCheck && !AirMap.hasValidCredentials() {
				observer.onError(AirMapErrorType.Unauthorized)
				return AnonymousDisposable {}
			}

			let encoding: ParameterEncoding = (method == Alamofire.Method.GET) ? .URL : .JSON

			let request = self.manager.request(method, self.baseUrl + url, parameters: params, encoding: encoding, headers: self.headers)
				.responseObject(keyPath: keyPath, mapToObject: object) { (response: Response<T?, NSError>) in
					if let error = response.result.error {
						AirMap.logger.error(method, String(T), url, error)
						observer.onError(error)
					} else {
						AirMap.logger.debug(String(T), "response:", response.result.value)
						observer.on(.Next(response.result.value ?? nil))
						observer.on(.Completed)
					}
			}
			return AnonymousDisposable {
				request.cancel()
			}
		}
	}

	func call<T: Mappable>(method: Alamofire.Method, url: String = "", params: [String: AnyObject] = [:], keyPath: String? = "data", authCheck: Bool = false) -> Observable<[T]> {

		return Observable.create { (observer: AnyObserver<[T]>) -> Disposable in

			if authCheck && !AirMap.hasValidCredentials() {
				observer.onError(AirMapErrorType.Unauthorized)
				return AnonymousDisposable {}
			}

			let encoding: ParameterEncoding = (method == .GET) ? .URL : .JSON

			let request = self.manager.request(method, self.baseUrl + url, parameters: params, encoding: encoding, headers: self.headers)
				.responseArray(keyPath: keyPath) { (response: Response<[T], NSError>) in
					if let error = response.result.error {

						AirMap.logger.error(method, String(T), url, error)
						observer.onError(error)
					} else {
						AirMap.logger.debug(String(T), "response:", response.result.value!)
						observer.on(.Next(response.result.value!))
						observer.on(.Completed)
					}
			}
			return AnonymousDisposable {
				request.cancel()
			}
		}
	}

	func call(method: Alamofire.Method, url: String = "", params: [String: AnyObject] = [:], keyPath: String? = "data", authCheck: Bool = false) -> Observable<Void> {

		return Observable.create { (observer: AnyObserver<Void>) -> Disposable in

			if authCheck && !AirMap.hasValidCredentials() {
				observer.onError(AirMapErrorType.Unauthorized)
				return AnonymousDisposable {}
			}

			let encoding: ParameterEncoding = (method == .GET) ? .URL : .JSON

			let request = self.manager.request(method, self.baseUrl + url, parameters: params, encoding: encoding, headers: self.headers)
				.response { _, _, _, error in
					if let error = error {
						AirMap.logger.error(method, url, error)
						observer.onError(error)
					} else {
						observer.on(.Next())
						observer.on(.Completed)
					}
			}
			return AnonymousDisposable {
				request.cancel()
			}
		}
	}
}
