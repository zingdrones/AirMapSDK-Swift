//
//  AirMap+Request.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/22/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

//
//  Request.swift
//  AlamofireObjectMapper
//
//  Created by Tristan Himmelman on 2015-04-30.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014-2015 Tristan Himmelman
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Alamofire
import ObjectMapper

extension Request {

	internal static func newError(code: Error.Code, failureReason: String) -> NSError {
		let errorDomain = "com.airmap.error"

		let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
		let returnError = NSError(domain: errorDomain, code: code.rawValue, userInfo: userInfo)

		return returnError
	}

	public static func ObjectMapperSerializer<T: Mappable>(keyPath: String?, mapToObject object: T? = nil, context: MapContext? = nil) -> ResponseSerializer<T, NSError> {
		return ResponseSerializer { request, response, data, error in
			guard error == nil else {
				return .Failure(error!)
			}

			guard let _ = data else {
				let failureReason = "Data could not be serialized. Input data was nil."
				let error = newError(.DataSerializationFailed, failureReason: failureReason)
				return .Failure(error)
			}

			let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
			let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
			let JSONToMap: AnyObject?

			if let responseError = responseError(result, statusCode: response?.statusCode) {
				return .Failure(responseError)
			}

			if let keyPath = keyPath where keyPath.isEmpty == false {
				JSONToMap = result.value?.valueForKeyPath(keyPath)
			} else {
				JSONToMap = result.value
			}

			if let object = object {
				Mapper<T>().map(JSONToMap, toObject: object)
				return .Success(object)
			} else if let parsedObject = Mapper<T>(context: context).map(JSONToMap) {
				return .Success(parsedObject)
			}

			let failureReason = "ObjectMapper failed to serialize response."
			let error = newError(.DataSerializationFailed, failureReason: failureReason)
			return .Failure(error)
		}
	}

	/**
	Adds a handler to be called once the request has finished.

	- parameter queue:             The queue on which the completion handler is dispatched.
	- parameter keyPath:           The key path where object mapping should be performed
	- parameter object:            An object to perform the mapping on to
	- parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped by ObjectMapper.

	- returns: The request.
	*/
	public func responseObject<T: Mappable>(queue queue: dispatch_queue_t? = nil, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil, completionHandler: Response<T, NSError> -> Void) -> Self {
		return response(queue: queue, responseSerializer: Request.ObjectMapperSerializer(keyPath, mapToObject: object, context: context), completionHandler: completionHandler)
	}

	public static func ObjectMapperArraySerializer<T: Mappable>(keyPath: String?, context: MapContext? = nil) -> ResponseSerializer<[T], NSError> {
		return ResponseSerializer { request, response, data, error in
			guard error == nil else {
				return .Failure(error!)
			}

			guard let _ = data else {
				let failureReason = "Data could not be serialized. Input data was nil."
				let error = newError(.DataSerializationFailed, failureReason: failureReason)
				return .Failure(error)
			}

			let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
			let result = JSONResponseSerializer.serializeResponse(request, response, data, error)

			if let responseError = responseError(result, statusCode: response?.statusCode) {
				return .Failure(responseError)
			}

			let JSONToMap: AnyObject?
			if let keyPath = keyPath where keyPath.isEmpty == false {
				JSONToMap = result.value?.valueForKeyPath(keyPath)
			} else {
				JSONToMap = result.value
			}

			if let parsedObject = Mapper<T>(context: context).mapArray(JSONToMap) {
				return .Success(parsedObject)
			}

			let failureReason = "ObjectMapper failed to serialize response."
			let error = newError(.DataSerializationFailed, failureReason: failureReason)
			return .Failure(error)
		}
	}

	/**
	Adds a handler to be called once the request has finished.

	- parameter queue: The queue on which the completion handler is dispatched.
	- parameter keyPath: The key path where object mapping should be performed
	- parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped by ObjectMapper.

	- returns: The request.
	*/
	public func responseArray<T: Mappable>(queue queue: dispatch_queue_t? = nil, keyPath: String? = nil, context: MapContext? = nil, completionHandler: Response<[T], NSError> -> Void) -> Self {
		return response(queue: queue, responseSerializer: Request.ObjectMapperArraySerializer(keyPath, context: context), completionHandler: completionHandler)
	}


	/**
	Parses the response and returns an NSError if the status code is greater or equal to 400.

	- parameter result: The result object
	- parameter statusCode: The HTTP Status Code

	- returns: NSError?
	*/
	public static func responseError(result: Result<AnyObject, NSError>, statusCode: Int? = nil) -> NSError? {

		guard let statusCode = statusCode else {
			return nil
		}

		if statusCode == 401 {
			AirMap.authSession.delegate?.airmapSessionShouldAuthenticate()
		}

		if statusCode >= 400 {

			switch statusCode {
			case 401:   return NSError(type: AirMapError.Unauthorized)
			case 402:   return NSError(type: AirMapError.PaymentRequired)
			case 403:   return NSError(type: AirMapError.Forbidden)
			case 404:   return NSError(type: AirMapError.NotFound)
			default:
				let errorObj = Mapper<AirMapApiError>().map(result.value?.valueForKeyPath("data"))
				let error = NSError(type: AirMapApiError.airMapErrorType(statusCode),
				                    description: errorObj?.errorDescription() ?? "Unkown Error",
				                    code: statusCode)

				return error
			}
		}

		return nil
	}

}
