//
//  HTTPClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/28/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import Alamofire
import Foundation

protocol ClassDecodable: class, Decodable {}

internal class HTTPClient {
	
	static let activity = ActivityTracker()
	
	enum MimeType: String {
		case JSON = "application/json"
	}
	
	enum Header: String {
		case accept = "Accept"
		case apiKey = "X-API-Key"
		case authorization = "Authorization"
	}
	
	let basePath: String
	
	private lazy var manager: SessionManager = {
		
		let host = AirMap.configuration.airMapDomain
		let keys = ServerTrustPolicy.publicKeys(in: AirMapBundle.core)
		let policies: [String: ServerTrustPolicy] = [
			host: ServerTrustPolicy.pinPublicKeys(publicKeys: keys, validateCertificateChain: true, validateHost: true)
		]
		let manager = AirMap.configuration.airMapPinCertificates ?
			SessionManager(serverTrustPolicyManager: ServerTrustPolicyManager(policies: policies)) : SessionManager()
		
		manager.adapter = AuthenticationAdapter()
		
		return manager
	}()
	
	init(basePath: String) {
		self.basePath = basePath
	}

	private enum ApiResponse<T: Decodable>: Decodable {
		case success(T)
		case fail(AirMapApiError)
		case error(String)

		enum CodingKeys: CodingKey {
			case status
			case data
			case message
		}

		enum Status: String, Decodable {
			case success
			case fail
			case error
		}

		init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			let status = try container.decode(Status.self, forKey: .status)

			switch status {
			case .success:
				self = .success(try container.decode(T.self, forKey: .data))
			case .error:
				self = .fail(try container.decode(AirMapApiError.self, forKey: .data))
			case .fail:
				self = .error(try container.decode(String.self, forKey: .message))
			}
		}
	}

	private struct PagedResponse<T: Decodable>: Decodable {
		struct Paging: Decodable {
			let limit: Int
			let total: Int
		}
		let paging: Paging
		let results: [T]
	}

	private let decoder: JSONDecoder = {

		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase

		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = Constants.AirMapApi.dateFormat
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		decoder.dateDecodingStrategy = .formatted(dateFormatter)

		return decoder
	}()

	internal func perform<T: ClassDecodable>(method: HTTPMethod, path: String = "", params: [String: Any] = [:], update object: inout T, checkAuth: Bool = false) -> Observable<T> {

		return Observable
			.create { [weak object, unowned self] (observer: AnyObserver<T>) -> Disposable in

				let request = self.manager
					.checkAuth(checkAuth)
					.request(self.absolute(path), method: method, parameters: [:], encoding: self.encoding(method), headers: nil)
					.responseData(completionHandler: { [unowned self] (response) in

						if let error = response.error { return observer.onError(error) }
						guard let data = response.data else { return observer.onError(AirMapError.serialization(.invalidData)) }

						do {
							switch try self.decoder.decode(ApiResponse<T>.self, from: data) {
							case .success(let value):
								if object != nil {
									object = value
								}
								observer.onNext(value)
								observer.onCompleted()
							case .error(let message):
								let error = AirMapApiError.init(message: message, code: 0)
								observer.onError(error)
							case .fail(let error):
								observer.onError(error)
							}
						}
						catch {
							observer.onError(error)
						}
					})

				return Disposables.create {
					request.cancel()
				}
			}
			.trackActivity(HTTPClient.activity)
	}

	internal func perform<T: Decodable>(method: HTTPMethod, path: String = "", params: [String: Any] = [:], checkAuth: Bool = false) -> Observable<T> {

		return Observable
			.create { (observer: AnyObserver<T>) -> Disposable in

				let request = self.manager
					.checkAuth(checkAuth)
					.request(self.absolute(path), method: method, parameters: [:], encoding: self.encoding(method), headers: nil)
					.responseData(completionHandler: { [unowned self] (response) in

						if let error = response.error { return observer.onError(error) }
						guard let data = response.data else { return observer.onError(AirMapError.serialization(.invalidData)) }

						do {
							switch try self.decoder.decode(ApiResponse<T>.self, from: data) {
							case .success(let value):
								observer.onNext(value)
								observer.onCompleted()
							case .error(let message):
								let error = AirMapApiError.init(message: message, code: 0)
								observer.onError(error)
							case .fail(let error):
								observer.onError(error)
							}
						}
						catch {
							observer.onError(error)
						}
					})

				return Disposables.create {
					request.cancel()
				}
			}
			.trackActivity(HTTPClient.activity)
	}

	internal func perform<T: Decodable>(method: HTTPMethod, path: String = "", params: [String: Any] = [:], update object: inout T, checkAuth: Bool = false) -> Observable<[T]> {

		return Observable
			.create { (observer: AnyObserver<[T]>) -> Disposable in

				let request = self.manager
					.checkAuth(checkAuth)
					.request(self.absolute(path), method: method, parameters: [:], encoding: self.encoding(method), headers: nil)
					.responseData(completionHandler: { [unowned self] (response) in

						if let error = response.error { return observer.onError(error) }
						guard let data = response.data else { return observer.onError(AirMapError.serialization(.invalidData)) }

						do {
							switch try self.decoder.decode(ApiResponse<PagedResponse<T>>.self, from: data) {
							case .success(let value):
								observer.onNext(value.results)
								observer.onCompleted()
							case .error(let message):
								let error = AirMapApiError.init(message: message, code: 0)
								observer.onError(error)
							case .fail(let error):
								observer.onError(error)
							}
						}
						catch {
							observer.onError(error)
						}
					})

				return Disposables.create {
					request.cancel()
				}
			}
			.trackActivity(HTTPClient.activity)
	}


	internal func perform(method: HTTPMethod, path: String = "", params: [String: Any] = [:], checkAuth: Bool = false) -> Observable<Void> {

		struct VoidResponse: Decodable {}

		return Observable
			.create { (observer: AnyObserver<Void>) -> Disposable in

				let request = self.manager
					.checkAuth(checkAuth)
					.request(self.absolute(path), method: method, parameters: [:], encoding: self.encoding(method), headers: nil)
					.responseData(completionHandler: { [unowned self] (response) in

						if let error = response.error { return observer.onError(error) }
						guard let data = response.data else { return observer.onError(AirMapError.serialization(.invalidData)) }

						do {
							switch try self.decoder.decode(ApiResponse<VoidResponse>.self, from: data) {
							case .success:
								observer.onNext(())
								observer.onCompleted()
							case .error(let message):
								let error = AirMapApiError.init(message: message, code: 0)
								observer.onError(error)
							case .fail(let error):
								observer.onError(error)
							}
						}
						catch {
							observer.onError(error)
						}
					})

				return Disposables.create {
					request.cancel()
				}
			}
			.trackActivity(HTTPClient.activity)
	}

	private func encoding(_ method: HTTPMethod) -> ParameterEncoding {
		return (method == .get || method == .delete) ? URLEncoding.queryString : JSONEncoding.default
	}
	
	private func absolute(_ path: String) -> String {
		return self.basePath + path.urlEncoded
	}
	
}

private extension SessionManager {
	
	func checkAuth(_ checkAuth: Bool) -> Self {
		
		if let authAdapter = adapter as? AuthenticationAdapter {
			authAdapter.checkAuth = checkAuth
		}
		return self
	}
}

private class AuthenticationAdapter: RequestAdapter {

	var checkAuth: Bool = false
	
	func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
		
		let apiKey = AirMap.configuration.airmap.apiKey
		let authToken = AirMap.authSession.authToken

		if checkAuth && !AirMap.hasValidCredentials() {
			throw AirMapError.unauthorized
			AirMap.authSession.delegate?.airmapSessionShouldAuthenticate()
		}
		
		var urlRequest = urlRequest
		
		let authorization = [AirMap.authSession.tokenType, authToken]
			.compactMap { $0 }
			.joined(separator: " ")

		urlRequest.setValue(authorization, forHTTPHeaderField: HTTPClient.Header.authorization.rawValue)
		urlRequest.setValue(apiKey, forHTTPHeaderField: HTTPClient.Header.apiKey.rawValue)
		urlRequest.setValue(HTTPClient.MimeType.JSON.rawValue, forHTTPHeaderField: HTTPClient.Header.accept.rawValue)

		return urlRequest
	}
}
