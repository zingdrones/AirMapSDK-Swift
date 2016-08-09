//
//  AirMapErrorResponse.swift
//
//  Created by Rocky Demoff on 7/19/16
//  Copyright (c) AirMap, Inc.. All rights reserved.
//

import ObjectMapper

public class AirMapApiError: Mappable {

	public var message: String = ""
	public var messages = [AirMapApiValidationErrors]()
	public var code: Int!

	required public init?(_ map: Map) {}

	public func mapping(map: Map) {
		message		<-  map["message"]
		messages	<-  map["errors"]
		code		<-  map["code"]
	}

	public func errorDescription() -> String {
		return messages
			.map { $0.name + ":" + $0.message }
			.joinWithSeparator("\n")
	}

	/// Returns an AirMapError from a Status Code
	class func airMapErrorType(statusCode: Int) -> AirMapError {

		switch statusCode {
		case AirMapError.Server.rawValue:
			return .Server
		case AirMapError.Unauthorized.rawValue:
			return .Unauthorized
		case AirMapError.PaymentRequired.rawValue:
			return .PaymentRequired
		case AirMapError.Forbidden.rawValue:
			return .Forbidden
		case AirMapError.NotFound.rawValue:
			return .NotFound
		case AirMapError.BadRequest.rawValue:
			return .BadRequest
		case AirMapError.Custom.rawValue:
			return .BadRequest
		default:
			return .Unknown
		}
	}
}


public class AirMapApiValidationErrors: Mappable {

	public var name: String = ""
	public var message: String = ""

	required public init?(_ map: Map) {}

	public func mapping(map: Map) {
		name     <-  map["name"]
		message  <-  map["message"]
	}
}

public enum AirMapErrorType: ErrorType {

	case Server
	case Unauthorized
	case PaymentRequired
	case Forbidden
	case NotFound
	case BadRequest
	case Custom
	case Unknown
}

public enum AirMapError: Int {

	case Unknown = -1
	case Custom = 0
	case BadRequest = 400
	case Unauthorized = 401
	case PaymentRequired = 402
	case Forbidden = 403
	case NotFound = 404
	case Server = 500

	func localizedUserInfo(description: String?) -> [String: String] {
		
		var localizedDescription: String

		switch self {
		case Unauthorized:
			localizedDescription = NSLocalizedString("Unauthorized.", comment: "Unauthorized")
		case NotFound:
			localizedDescription = NSLocalizedString("Not Found.", comment: "Not Found")
		case BadRequest:
			localizedDescription = NSLocalizedString("Bad Request.", comment: "Bad Request")
		case .Forbidden:
			localizedDescription = NSLocalizedString("Forbidden.", comment: "Bad Request")
		default:
			localizedDescription = NSLocalizedString("Unknown Error.", comment: "Unknown Error")
		}

		if let paramDescription = description {
			localizedDescription = NSLocalizedString(paramDescription, comment: paramDescription)
		}

		return [
			NSLocalizedDescriptionKey: localizedDescription,
			NSLocalizedFailureReasonErrorKey: "",
			NSLocalizedRecoverySuggestionErrorKey: ""
		]
	}
}


extension NSError {

	public convenience init(type: AirMapError) {
		self.init(domain: "com.airmap.error", code: type.rawValue, userInfo: type.localizedUserInfo(nil))
	}

	public convenience init(type: AirMapError, description: String, code: Int) {
		self.init(domain: "com.airmap.error", code: code, userInfo: type.localizedUserInfo(description))
	}
}
