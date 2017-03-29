//
//  AirMapError.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 2/3/17.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public enum Auth0Error: Error {
	
	case network(Error)
	case unauthorized
	case invalidRequest(Error)
	case client(Error)
	case server
	case serialization(AirMapSerializationError)
	case unknown(underlying: Error)
}

extension Auth0Error: RawRepresentable {
	
	public typealias RawValue = (request: URLRequest?, response: HTTPURLResponse, data: Data)

	public var rawValue: RawValue {
		fatalError("RawValue getter unavailable")
	}
	
	public init?(rawValue: RawValue) {
		
		let code = rawValue.response.statusCode
		
		switch code {
			
		case 400:
			let error = Auth0Error.error(from: rawValue)
			self = .invalidRequest(error)
			
		case 401:
			self = .unauthorized
			
		case 404:
			let path = rawValue.request!.url!.path
			let error = Auth0ApiError(message: "Invalid URL: \(path)", code: code)
			self = .client(error)
			
		case 422:
			let error = Auth0Error.error(from: rawValue)
			self = .invalidRequest(error)
			
		case 400..<500:
			let error = Auth0Error.error(from: rawValue)
			self = .client(error)
			
		case 500..<600:
			self = .server
			
		default:
			return nil
		}
	}
	
	private static func error(from rawValue: RawValue) -> Error {

		if let json = try? JSONSerialization.jsonObject(with: rawValue.data, options: .allowFragments),
			let error = Mapper<Auth0ApiError>().map(JSONObject: json) {
			return error
		} else {
			let code = rawValue.response.statusCode
			return Auth0ApiError(message: String(format: LocalizedStrings.Error.genericFormat, code.description), code: code)
		}
	}
}

extension Auth0Error: CustomStringConvertible {
	
	public var description: String {
		
		let localized = LocalizedStrings.Error.self
		
		switch self {
		case .network(let error):
			return error.localizedDescription
		case .unauthorized:
			return localized.unauthorized
		case .invalidRequest(let error):
			return error.localizedDescription
		case .client(let error):
			return error.localizedDescription
		case .server:
			return localized.server
		case .serialization:
			return localized.serialization
		case .unknown(let error):
			return error.localizedDescription
		}
	}
}

public struct Auth0ApiError: Mappable {
	
	public internal(set) var message: String!
	public internal(set) var code: Int!
	
	internal init(message: String, code: Int) {
		self.message = message
		self.code = code
	}
	
	public init?(map: Map) {
		guard map.JSON["error"] is String else {
			return nil
		}
	}
	
	public mutating func mapping(map: Map) {
		message   <-  map["error_description"]
	}
}

extension Auth0ApiError: LocalizedError {

	public var localizedDescription: String {
		return message
	}
}
