//
//  HTTPClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/28/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa
import Alamofire
import ObjectMapper

internal class HTTPClient {
	
	enum MimeType: String {
		case JSON = "application/json"
	}
	
	enum Header: String {
		case accept        = "Accept"
		case authorization = "Authorization"
		case apiKey        = "X-API-Key"
	}
	
	let basePath: String!
	
	private lazy var manager: SessionManager = {
		
		let host = NSURL(string: Config.AirMapApi.host)!.host!
		let keys = ServerTrustPolicy.publicKeys(in: AirMapBundle.core)
		
		let serverTrustPolicies: [String: ServerTrustPolicy] = [
			host: ServerTrustPolicy.pinPublicKeys(publicKeys: keys, validateCertificateChain: true, validateHost: true)
		]

		let manager = AirMap.authSession.enableCertificatePinning ?
			SessionManager(serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)) : SessionManager()
		
		manager.adapter = AuthenticationAdapter()
		
		return manager
	}()
	
	init(basePath: String) {
		self.basePath = basePath
	}
	
	internal func perform<T: BaseMappable>(method: HTTPMethod, path: String = "", params: [String: Any] = [:], keyPath: String? = "data", update object: T? = nil, checkAuth: Bool = false) -> Observable<T> {
		
		return Observable.create { (observer: AnyObserver<T>) -> Disposable in
			
			let request = self.manager
				.checkAuth(checkAuth)
				.request(self.absolute(path), method: method, parameters: params, encoding: self.encoding(method))
				.airMapResponseObject(keyPath: keyPath, mapTo: object) { response in
					if let error = response.result.error {
						AirMap.logger.error(method, String(describing: T.self), path, error)
						observer.onError(error)
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
	
	internal func perform<T: BaseMappable>(method: HTTPMethod, path: String = "", params: [String: Any] = [:], keyPath: String? = "data", update object: T? = nil, checkAuth: Bool = false) -> Observable<T?> {
		
		return Observable.create { (observer: AnyObserver<T?>) -> Disposable in
			
			let request = self.manager
				.checkAuth(checkAuth)
				.request(self.absolute(path), method: method, parameters: params, encoding: self.encoding(method))
				.airMapResponseObject(keyPath: keyPath, mapTo: object) { response in
					if let error = response.result.error {
						AirMap.logger.error(method, String(describing: T.self), path, error)
						observer.onError(error)
					} else {
						AirMap.logger.debug(String(describing: T.self), "response:", response.result.value as Any)
						observer.on(.next(response.result.value ?? nil))
						observer.on(.completed)
					}
			}
			return Disposables.create {
				request.cancel()
			}
		}
	}
	
	internal func perform<T: BaseMappable>(method: HTTPMethod, path: String = "", params: [String: Any] = [:], keyPath: String? = "data", checkAuth: Bool = false) -> Observable<[T]> {
		
		return Observable.create { (observer: AnyObserver<[T]>) -> Disposable in
			
			let request = self.manager
				.checkAuth(checkAuth)
				.request(self.absolute(path), method: method, parameters: params, encoding: self.encoding(method))
				.airMapResponseArray(keyPath: keyPath) { (response: DataResponse<[T]>) in
					if let error = response.result.error {
						AirMap.logger.error(method, String(describing: T.self), path, error)
						observer.onError(error)
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
	
	internal func perform(method: HTTPMethod, path: String = "", params: [String: Any] = [:], keyPath: String? = "data", checkAuth: Bool = false) -> Observable<Void> {

		return Observable.create { (observer: AnyObserver<Void>) -> Disposable in
			
			let request = self.manager
				.checkAuth(checkAuth)
				.request(self.absolute(path), method: method, parameters: params, encoding: self.encoding(method))
				.airMapVoidResponse { (response: DataResponse<Void>) in
					if let error = response.error {
						AirMap.logger.error(method, path, error)
						observer.onError(error)
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
	
	private func encoding(_ method: HTTPMethod) -> ParameterEncoding {
		
		return (method == .get || method == .delete) ? URLEncoding.queryString : JSONEncoding.default
	}
	
	private func absolute(_ path: String) -> String {
		
		return self.basePath + path.urlEncoded
	}
	
}

extension SessionManager {
	
	func checkAuth(_ checkAuth: Bool) -> Self {
		
		if let authAdapter = adapter as? AuthenticationAdapter {
			authAdapter.checkAuth = checkAuth
		}
		return self
	}
}

class AuthenticationAdapter: RequestAdapter {

	var checkAuth: Bool = false
	
	func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
		
		let apiKey = AirMap.configuration.airMapApiKey
		let authToken = AirMap.authSession.authToken

		if checkAuth && !AirMap.hasValidCredentials() {
			throw AirMapError.unauthorized
			AirMap.authSession.delegate?.airmapSessionShouldAuthenticate()
		}
		
		var urlRequest = urlRequest
		
		let authorization = [AirMap.authSession.tokenType, authToken]
			.flatMap { $0 }
			.joined(separator: " ")

		urlRequest.setValue(authorization, forHTTPHeaderField: HTTPClient.Header.authorization.rawValue)
		urlRequest.setValue(apiKey, forHTTPHeaderField: HTTPClient.Header.apiKey.rawValue)
		urlRequest.setValue(HTTPClient.Header.accept.rawValue, forHTTPHeaderField: HTTPClient.MimeType.JSON.rawValue)
		
		return urlRequest
	}
}

extension DataRequest {
	
	/// Converts the response into a BaseMappable object
	func airMapResponseObject<T: BaseMappable>(keyPath: String? = nil, mapTo object: T? = nil, context: MapContext? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
		
		let serializer: DataResponseSerializer<T> = DataRequest.airMapSerializer(keyPath, mapToObject: object, context: context)
		return response(queue: nil, responseSerializer: serializer, completionHandler: completionHandler)
	}
	
	/// Converts the response into an array of BaseMappable objects
	func airMapResponseArray<T: BaseMappable>(keyPath: String? = nil, context: MapContext? = nil, completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Self {
		
		let serializer: DataResponseSerializer<[T]> = DataRequest.airMapSerializer(keyPath, context: context)
		return response(queue: nil, responseSerializer: serializer, completionHandler: completionHandler)
	}
	
	/// Converts the response into Void
	func airMapVoidResponse(completionHandler: @escaping (DataResponse<Void>) -> Void) -> Self {
		
		let serializer: DataResponseSerializer<Void> = DataRequest.airMapSerializer()
		return response(queue: nil, responseSerializer: serializer, completionHandler: completionHandler)
	}

	/// Void serializer
	public static func airMapSerializer() -> DataResponseSerializer<Void> {
		
		return DataResponseSerializer { request, response, data, error in
			
			do {
				// Ensure we received a reponse, else throw error
				guard let response = response else {
					throw AirMapError.network(error!)
				}
				// Ensure we have a valid data response (not nil)
				let data = try validatedData(from: response, data: data)

				// Catch any error-related http codes and body
				try catchApiError(with: response, from: request, with: data)
				
				return .success()
			}
			catch let error {
				return .failure(error)
			}
		}
	}

	/// Single object serializer
	public static func airMapSerializer<T: BaseMappable>(_ keyPath: String?, mapToObject object: T? = nil, context: MapContext? = nil) -> DataResponseSerializer<T> {
		
		return DataResponseSerializer { request, response, data, error in
			
			do {
				// Ensure we received a reponse, else throw error
				guard let response = response else {
					throw AirMapError.network(error!)
				}
				// Ensure we have a valid data response (not nil)
				let data = try validatedData(from: response, data: data)

				// Catch any error-related http codes and body
				try catchApiError(with: response, from: request, with: data)

				// Parse json from response body
				let json = try jsonObjectFrom(response: response, json: data, keyPath: keyPath)
				
				// Map the json to the target object if provided else return a new object
				if let object = object {
					_ = Mapper<T>().map(JSONObject: json, toObject: object)
					return .success(object)
				} else if let mappedObject = Mapper<T>(context: context).map(JSONObject: json) {
					return .success(mappedObject)
				} else {
					return .failure(AirMapError.serialization(.invalidObject))
				}
			}
			catch let error {
				return .failure(error)
			}
		}
	}
	
	/// Array serializer
	public static func airMapSerializer<T: BaseMappable>(_ keyPath: String?, context: MapContext? = nil) -> DataResponseSerializer<[T]> {
		
		return DataResponseSerializer { request, response, data, error in
			
			do {
				// Ensure we received a reponse, else throw error
				guard let response = response else {
					throw AirMapError.network(error!)
				}
				// Ensure we have a valid data response (not nil)
				let data = try validatedData(from: response, data: data)
				
				// Catch any error-related http codes and body
				try catchApiError(with: response, from: request, with: data)

				// Parse json from response body
				let json = try jsonObjectFrom(response: response, json: data, keyPath: keyPath)
				
				// Map the json to a new object
				if let parsedObjects: [T] = Mapper<T>(context: context).mapArray(JSONObject: json) {
					return .success(parsedObjects)
				} else {
					return .failure(AirMapError.serialization(.invalidObject))
				}
			}
			catch let error {
				return .failure(error)
			}
		}
	}
	
	/// Returns a json object from the response payload. Throws an error if unable to serialize.
	private static func jsonObjectFrom(response: HTTPURLResponse, json data: Data, keyPath: String?) throws -> Any? {
		
		let jsonResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
		let result = jsonResponseSerializer.serializeResponse(nil, response, data, nil)
		
		guard case .success = result else {
			throw AirMapError.serialization(.invalidJson)
		}
		
		let JSONToMap: Any?
		if let keyPath = keyPath, !keyPath.isEmpty {
			JSONToMap = (result.value as AnyObject?)?.value(forKeyPath: keyPath)
		} else {
			JSONToMap = result.value
		}
		
		return JSONToMap
	}
	
	/// 
	private static func validatedData(from response: HTTPURLResponse, data: Data?) throws -> Data {
		
		let serializedData = Request.serializeResponseData(response: response, data: data, error: nil)

		switch serializedData {
		case .success(let data):
			return data
		case .failure:
			throw AirMapError.serialization(.invalidData)
		}
	}
	
	/// Adapts a generic underlying error to an AirMapError
	private static func catchApiError(with response: HTTPURLResponse, from request: URLRequest?, with data: Data) throws {

		if let error = AirMapError(rawValue: (request, response, data)) {
			
			throw error
			
		} else if let error = Auth0Error(rawValue: (request, response, data)) {
		
			throw error
		}
	}
	
}
