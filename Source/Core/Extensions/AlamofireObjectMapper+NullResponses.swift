//
//  AlamofireObjectMapper+NullResponses.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/5/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

//import ObjectMapper
//import Alamofire
//
//extension Request {
//	
//	public static func ObjectMapperSerializer<T: Mappable>(_ keyPath: String?, mapToObject object: T? = nil) -> DataResponseSerializer<T?> {
//		
//		return DataResponseSerializer { request, response, data, error in
//			guard error == nil else {
//				return .failure(error!)
//			}
//			
//			guard data != nil else {
//				let failureReason = "Data could not be serialized. Input data was nil."
//				let error  = Request.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
//				return .Failure(error)
//			}
//			
//			let serializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
//			let result = serializer.serializeResponse(request, response, data, error)
//			
//			let JSONToMap: AnyObject?
//			if let keyPath = keyPath, keyPath.isEmpty == false {
//				JSONToMap = result.value?.valueForKeyPath(keyPath)
//			} else {
//				JSONToMap = result.value
//			}
//			
//			if let object = object {
//				Mapper<T>().map(JSONToMap, toObject: object)
//				return .success(object)
//			} else if let parsedObject = Mapper<T>().map(JSONToMap) {
//				return .Success(parsedObject)
//			} else if JSONToMap != nil {
//				return .success(nil)
//			}
//			
//			let failureReason = "ObjectMapper failed to serialize response."
//			let error = Request.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
//			return .Failure(error)
//		}
//	}
//	
//	fileprivate static func errorWithCode(_ code: Error.Code, failureReason: String) -> Error {
//		let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
//		return Error(domain: "com.airmap.airmapsdk", code: code.rawValue, userInfo: userInfo)
//	}
//	
//	/**
//	Adds a handler to be called once the request has finished.
//	
//	- parameter queue:             The queue on which the completion handler is dispatched.
//	- parameter keyPath:           The key path where object mapping should be performed
//	- parameter object:            An object to perform the mapping on to
//	- parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped by ObjectMapper.
//	
//	- returns: The request.
//	*/
//	public func responseObject<T: Mappable>(_ queue: dispatch_queue_t? = nil, keyPath: String? = nil, mapToObject object: T? = nil, completionHandler: (Response<T?, Error>) -> Void) -> Self {
//		return response(queue: queue, responseSerializer: Request.ObjectMapperSerializer(keyPath, mapToObject: object), completionHandler: completionHandler)
//	}
//	
//	
//}
