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
	
		let authorizationValue = [AirMap.authSession.tokenType, AirMap.authSession.authToken]
			.flatMap{$0}
			.joinWithSeparator(" ")
		
		return [
			Header.Accept.rawValue: MimeType.JSON.rawValue,
			Header.XApiKey.rawValue: AirMap.configuration.airMapApiKey,
			Header.Authorization.rawValue: authorizationValue
		]
	}

	lazy var manager: Manager = {

		let host = NSURL(string: Config.AirMapApi.host)!.host!
		let certs = ServerTrustPolicy.certificatesInBundle(AirMapBundle.mainBundle())
		
		let serverTrustPolicies: [String: ServerTrustPolicy] = [
			host: ServerTrustPolicy.PinCertificates(certificates: certs, validateCertificateChain: true, validateHost: true)
		]
		
		return AirMap.authSession.enableCertificatePinning ?
			Manager(serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)) : Manager()

	}()

	init(_ baseUrl: String) {
		self.baseUrl = baseUrl
	}
	
	func call<T: Mappable>(method: Alamofire.Method, url: String = "", params: [String: AnyObject] = [:], keyPath: String? = "data", update object: T? = nil, authCheck: Bool = false) -> Observable<T> {

		return Observable.create { (observer: AnyObserver<T>) -> Disposable in

			if authCheck && !AirMap.hasValidCredentials() {
				observer.onError(AirMapErrorType.Unauthorized)
				AirMap.authSession.delegate?.airmapSessionShouldAuthenticate()
				return NopDisposable.instance
			}

			let request = self.manager.request(method, self.baseUrl + url.urlEncoded, parameters: params, encoding: self.encoding(method), headers: self.headers)
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
				AirMap.authSession.delegate?.airmapSessionShouldAuthenticate()
				return NopDisposable.instance
			}

			let request = self.manager.request(method, self.baseUrl + url.urlEncoded, parameters: params, encoding: self.encoding(method), headers: self.headers)
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
				AirMap.authSession.delegate?.airmapSessionShouldAuthenticate()
				return NopDisposable.instance
			}

			let request = self.manager.request(method, self.baseUrl + url.urlEncoded, parameters: params, encoding: self.encoding(method), headers: self.headers)
				.responseArray(keyPath: keyPath) { (response: Response<[T], NSError>) in
					if let error = response.result.error {
						AirMap.logger.error(method, String(T), url, error)
						observer.onError(error)
					} else {
						let resultValue = response.result.value!
						AirMap.logger.debug("Response:", resultValue.count, String(T)+"s")
						observer.on(.Next(resultValue))
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
				AirMap.authSession.delegate?.airmapSessionShouldAuthenticate()
				return NopDisposable.instance
			}

			let request = self.manager.request(method, self.baseUrl + url.urlEncoded, parameters: params, encoding: self.encoding(method), headers: self.headers)
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
	
	private func encoding(method: Alamofire.Method) -> ParameterEncoding {
		return (method == .GET) ? .URL : .JSON
	}
}
