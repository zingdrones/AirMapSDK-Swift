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
	
	case networkOffline
	case unauthorized
	case badRequest(underlying: AirMapApiError)
	case httpError(underlying: AirMapHTTPError)
}

public class AirMapApiError: Mappable, LocalizedError {
	
	public var message: String = ""
	public var messages = [AirMapApiValidationErrors]()
	public var code: Int!
	
	required public init?(map: Map) {}
	
	public func mapping(map: Map) {
		message   <-  map["message"]
		messages  <-  map["errors"]
		code      <-  map["code"]
	}
	
	public var localizedDescription: String {
		
		if messages.count == 0 {
			return message
		} else {
			return messages.map { $0.name + ":" + $0.message }.joined(separator: "\n")
		}
	}
}

public class AirMapApiValidationErrors: Mappable {
	
	public var name: String = ""
	public var message: String = ""
	
	required public init?(map: Map) {}
	
	public func mapping(map: Map) {
		name     <-  map["name"]
		message  <-  map["message"]
	}
}

public enum AirMapHTTPError: Error {
	
	public enum StatusClass: RawRepresentable {
		
		public typealias RawValue = (code: Int, error: AirMapHTTPError?)
		
		case informational
		case success
		case redirection
		case client(Error)
		case server(Error)
		
		public var rawValue: RawValue {
			fatalError("Raw value getter not implemented")
		}
		
		public init?(rawValue: RawValue) {
			
			switch rawValue.code {
			case 100..<200:
				self = .informational
			case 200..<300:
				self = .success
			case 300..<400:
				self = .redirection
			case 400..<500:
				guard let error = rawValue.error else { return nil }
				self = .client(error)
			case 500..<600:
				guard let error = rawValue.error else { return nil }
				self = .server(error)
			default:
				return nil
			}
		}
		
		public var underlyingError: Error? {
			switch self {
			case .client(let error):
				return error
			case .server(let error):
				return error
			default:
				return nil
			}
		}
	}
}
