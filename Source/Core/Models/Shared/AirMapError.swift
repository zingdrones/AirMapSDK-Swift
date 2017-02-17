//
//  AirMapError.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 2/3/17.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public enum AirMapError: Error {
	
	case network(Error)
	
	case unauthorized
	case invalidRequest(Error)

	case client(Error)
	case server
	
	case serialization(AirMapSerializationError)
	
	case unknown(underlying: Error)
}

extension AirMapError: RawRepresentable {
	
	public typealias RawValue = (request: URLRequest?, response: HTTPURLResponse, data: Data)

	public var rawValue: RawValue {
		fatalError("RawValue getter unavailable")
	}
	
	public init?(rawValue: RawValue) {
		
		let code = rawValue.response.statusCode
		
		switch code {
			
		case 400:
			let error = AirMapError.error(from: rawValue)
			self = .invalidRequest(error)
			
		case 401:
			self = .unauthorized
			
		case 404:
			let path = rawValue.request!.url!.path
			let error = AirMapApiError(message: "Invalid URL: \(path)", code: code)
			self = .client(error)
			
		case 422:
			let error = AirMapError.error(from: rawValue)
			self = .invalidRequest(error)
			
		case 400..<500:
			let error = AirMapError.error(from: rawValue)
			self = .client(error)
			
		case 500..<600:
			self = .server
			
		default:
			return nil
		}
	}
	
	private static func error(from rawValue: RawValue) -> Error {

		if let json = try? JSONSerialization.jsonObject(with: rawValue.data, options: .allowFragments),
			let error = Mapper<AirMapApiError>().map(JSONObject: json) {
			return error
		} else {
			let code = rawValue.response.statusCode
			return AirMapApiError(message: "The server returned an error. (\(code))", code: code)
		}
	}
}

extension AirMapError: LocalizedError {
	
	public var localizedDescription: String {
		switch self {
		case .network(let error):
			return error.localizedDescription
		case .unauthorized:
			return "Unauthorized. Please check login credentials."
		case .invalidRequest(let error):
			return error.localizedDescription
		case .client(let error):
			return error.localizedDescription
		case .server:
			return "The server could not complete your request."
		case .serialization:
			return "A response serialization error has occurred."
		case .unknown(let error):
			return error.localizedDescription
		}
	}
}

public enum AirMapSerializationError: Error {
	
	case invalidData
	case invalidJson
	case invalidObject
}

public struct AirMapApiError: Mappable {
	
	public internal(set) var message: String!
	public internal(set) var messages = [AirMapApiParameterError]()
	public internal(set) var code: Int!
	
	internal init(message: String, code: Int) {
		self.message = message
		self.code = code
	}
	
	public init?(map: Map) {
		guard let status = map.JSON["status"] as? String, status == "fail" else {
			return nil
		}
	}
	
	public mutating func mapping(map: Map) {
		message   <-  map["data.message"]
		messages  <-  map["data.errors"]
		code      <-  map["data.code"]
	}
}

extension AirMapApiError: LocalizedError {

	public var localizedDescription: String {
		if messages.count == 0 {
			return message
		} else {
			return messages.map { $0.name + ": " + $0.message }.joined(separator: "\n")
		}
	}
}

public struct AirMapApiParameterError: Mappable {
	
	public internal(set) var name: String!
	public internal(set) var message: String!
	
	public init?(map: Map) {
		guard map.JSON["name"] as? String != nil, map.JSON["message"] as? String != nil else {
			return nil
		}
	}
	
	public mutating func mapping(map: Map) {
		name     <-  map["name"]
		message  <-  map["message"]
	}
}
