//
//  AlamofireObjectMapper+NullResponses.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/5/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper
import Alamofire

extension Request {

	public static func ObjectMapperSerializer<T: Mappable>(keyPath: String?, mapToObject object: T? = nil) -> ResponseSerializer<T?, NSError> {
		return ResponseSerializer { request, response, data, error in
			guard error == nil else {
				return .Failure(error!)
			}

			guard let _ = data else {
				let failureReason = "Data could not be serialized. Input data was nil."
				let error  = Request.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
				return .Failure(error)
			}

			let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
			let result = JSONResponseSerializer.serializeResponse(request, response, data, error)

			let JSONToMap: AnyObject?
			if let keyPath = keyPath where keyPath.isEmpty == false {
				JSONToMap = result.value?.valueForKeyPath(keyPath)
			} else {
				JSONToMap = result.value
			}

			if let object = object {
				Mapper<T>().map(JSONToMap, toObject: object)
				return .Success(object)
			} else if let parsedObject = Mapper<T>().map(JSONToMap) {
				return .Success(parsedObject)
			} else if JSONToMap != nil {
				return .Success(nil)
			}

			let failureReason = "ObjectMapper failed to serialize response."
			let error = Request.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
			return .Failure(error)
		}
	}

	private static func errorWithCode(code: Error.Code, failureReason: String) -> NSError {
		let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
		return NSError(domain: "com.airmap.airmapsdk", code: code.rawValue, userInfo: userInfo)
	}

	/**
	Adds a handler to be called once the request has finished.

	- parameter queue:             The queue on which the completion handler is dispatched.
	- parameter keyPath:           The key path where object mapping should be performed
	- parameter object:            An object to perform the mapping on to
	- parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped by ObjectMapper.

	- returns: The request.
	*/
	public func responseObject<T: Mappable>(queue queue: dispatch_queue_t? = nil, keyPath: String? = nil, mapToObject object: T? = nil, completionHandler: Response<T?, NSError> -> Void) -> Self {
		return response(queue: queue, responseSerializer: Request.ObjectMapperSerializer(keyPath, mapToObject: object), completionHandler: completionHandler)
	}


}
