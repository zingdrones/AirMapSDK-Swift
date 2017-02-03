//
//  HTTPClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/28/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Alamofire
import ObjectMapper
import AlamofireObjectMapper
import RxSwift

internal class HTTPClient {

	private enum MimeType: String {
		case JSON = "application/json"
	}

	private enum Header: String {
		case Accept        = "Accept"
		case Authorization = "Authorization"
		case CacheControl  = "Cache-Control"
		case XApiKey       = "X-API-Key"
	}
	
	private let basePath: String!
	
	private var headers: [String: String] {
	
		let authorizationValue = [AirMap.authSession.tokenType, AirMap.authSession.authToken]
			.flatMap { $0 }
			.joined(separator: " ")
		
		return [
			Header.Accept.rawValue: MimeType.JSON.rawValue,
			Header.XApiKey.rawValue: AirMap.configuration.airMapApiKey!,
			Header.Authorization.rawValue: authorizationValue
		]
	}

	private lazy var manager: SessionManager = {

		let host = NSURL(string: Config.AirMapApi.host)!.host!
		let certs = ServerTrustPolicy.certificates(in: AirMapBundle.mainBundle)
		
		let serverTrustPolicies: [String: ServerTrustPolicy] = [
			host: ServerTrustPolicy.pinCertificates(certificates: certs, validateCertificateChain: true, validateHost: true)
		]
		
		return AirMap.authSession.enableCertificatePinning ?
			SessionManager(serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)) : SessionManager()
	}()

	init(basePath: String) {
		self.basePath = basePath
	}
	
	internal func perform<T: Mappable>(method: HTTPMethod, path: String = "", params: [String: Any] = [:], keyPath: String? = "data", update object: T? = nil, authCheck: Bool = false) -> Observable<T> {

		return Observable.create { (observer: AnyObserver<T>) -> Disposable in

			if authCheck && !AirMap.hasValidCredentials() {
				observer.onError(AirMapError.unauthorized)
				AirMap.authSession.delegate?.airmapSessionShouldAuthenticate()
				return Disposables.create()
			}

			let absolutePath = self.basePath + path.urlEncoded
			let request = self.manager.request(absolutePath, method: method, parameters: params, encoding: self.encoding(method), headers: self.headers)
				.responseObject(keyPath: keyPath, mapToObject: object) { response in
					if let error = response.result.error {
						AirMap.logger.error(method, String(describing: T.self), path, error)
						observer.onError(HTTPClient.adapt(error: error))
					} else {
						AirMap.logger.debug(String(describing: T.self), "response:", response.result.value!)
						observer.on(.next(response.result.value!))
						observer.on(.completed)
					}
				}
			
			return Disposables.create {
				request.cancel()
			}
		}
	}
	
	internal func perform<T: Mappable>(method: HTTPMethod, path: String = "", params: [String: Any] = [:], keyPath: String? = "data", update object: T? = nil, authCheck: Bool = false) -> Observable<T?> {

		return Observable.create { (observer: AnyObserver<T?>) -> Disposable in
			
			if authCheck && !AirMap.hasValidCredentials() {
				observer.onError(AirMapError.unauthorized)
				AirMap.authSession.delegate?.airmapSessionShouldAuthenticate()
				return Disposables.create()
			}

			let fullUrl = self.basePath + path.urlEncoded
			let request = self.manager
				.request(fullUrl, method: method, parameters: params, encoding: self.encoding(method), headers: self.headers)
				.responseObject(keyPath: keyPath, mapToObject: object) { response in
					if let error = response.result.error {
						AirMap.logger.error(method, String(describing: T.self), path, error)
						observer.onError(HTTPClient.adapt(error: error))
					} else {
						AirMap.logger.debug(String(describing: T.self), "response:", response.result.value)
						observer.on(.next(response.result.value ?? nil))
						observer.on(.completed)
					}
			}
			return Disposables.create {
				request.cancel()
			}
		}
	}

	internal func perform<T: Mappable>(method: HTTPMethod, path: String = "", params: [String: Any] = [:], keyPath: String? = "data", authCheck: Bool = false) -> Observable<[T]> {

		return Observable.create { (observer: AnyObserver<[T]>) -> Disposable in

			if authCheck && !AirMap.hasValidCredentials() {
				observer.onError(AirMapError.unauthorized)
				AirMap.authSession.delegate?.airmapSessionShouldAuthenticate()
				return Disposables.create()
			}

			let absolutePath = self.basePath + path.urlEncoded
			let request = self.manager
				.request(absolutePath, method: method, parameters: params, encoding: self.encoding(method), headers: self.headers)
				.responseArray(keyPath: keyPath) { (response: DataResponse<[T]>) in
					if let error = response.result.error {
						AirMap.logger.error(method, String(describing: T.self), path, error)
						observer.onError(HTTPClient.adapt(error: error))
					} else {
						let resultValue = response.result.value!
						AirMap.logger.debug("Response:", resultValue.count, String(describing: T.self)+"s")
						observer.on(.next(resultValue))
						observer.on(.completed)
					}
			}
			return Disposables.create() {
				request.cancel()
			}
		}
	}

	internal func perform(method: HTTPMethod, path: String = "", params: [String: Any] = [:], keyPath: String? = "data", authCheck: Bool = false) -> Observable<Void> {

		return Observable.create { (observer: AnyObserver<Void>) -> Disposable in

			if authCheck && !AirMap.hasValidCredentials() {
				observer.onError(AirMapError.unauthorized)
				AirMap.authSession.delegate?.airmapSessionShouldAuthenticate()
				return Disposables.create()
			}

			let fullUrl = self.basePath + path.urlEncoded
			let request = self.manager
				.request(fullUrl, method: method, parameters: params, encoding: self.encoding(method), headers: self.headers)
				.response() { response in
					if let error = response.error {
						AirMap.logger.error(method, path, error)
						observer.onError(HTTPClient.adapt(error: error))
					} else {
						observer.on(.next())
						observer.on(.completed)
					}
			}
			return Disposables.create() {
				request.cancel()
			}
		}
	}
	
	private static func adapt(error: Error) -> Error {
		
		// TODO Adapt error
		return error
	}
	
	private func encoding(_ method: HTTPMethod) -> ParameterEncoding {
		
		return (method == .get || method == .delete) ? URLEncoding.queryString : JSONEncoding.default
	}
	
}
