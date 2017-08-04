//
//  AirMapFlightBriefing.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 5/21/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

/// A pre-flight summary of the status, rulesets, validations, and authorizations pertinent to the operation of a flight
public struct AirMapFlightBriefing {
	
	/// The date and time the briefing was created
	public let createdAt: Date
	
	/// A list of rulesets containing rules selected and applicable to the operation
	public let rulesets: [Ruleset]
	
	/// The airspace and advisories that intersect with the flight plan
	public let status: AirMapAirspaceAdvisoryStatus
	
	/// The list of authorizations necessary to perform the flight
	public let authorizations: [Authorization]

	/// The list of validations performed on the flight plan's flight feature values
	public let validations: [Validation]

	/// A logical grouping of rules, typically under a specific jurisdiction
	public struct Ruleset {

		/// The unique identifier for the ruleset
		public let id: String
		
		/// A list of rules applicable to the operation
		public let rules: [AirMapRule]
	}
	
	/// A representation of the validation of a flight feature performed by AirMap or a third-party authority
	public struct Validation {
		
		/// The status of the validation
		public let status: Status
		
		/// The flight feature that is being validated
		public let feature: Feature
		
		/// The authoritative entity performing the validation
		public let authority: AirMapAuthority
		
		/// A message returned by the validation engine or upstream entity
		public let message: String
		
		/// A enumeration of the possible validation states
		///
		/// - valid: The flight feature value was deemed valid by the authority
		/// - invalid: The flight feature value was deemed invalid by the authority
		/// - unknown: The flight feature could not be validated
		public enum Status: String {
			case valid
			case invalid
			case unknown
		}
		
		public struct Feature {
			/// That unique identifier for the feature being validated
			let code: String
			/// A description of the flight feature being validated
			let name: String
		}
	}
	
	/// A representation of an authorization or permission required to perform a flight in a given jurisdiction by an authoritive entity
	public struct Authorization {
		
		/// The authoritive entity issuing the authorization
		public let authority: AirMapAuthority

		/// The authorization status of the flight plan
		public let status: Status
		
		/// A textual message describing the current status of the request
		public let message: String
	
		/// A enumeration of the possible authorization states
		///
		/// - pending: The request with the authority has been made and a response is pending
		/// - accepted: The request with the authority has been accepted
		/// - rejected: The request with the authority has been rejected
		/// - acceptedUponSubmission: The request with the authority will be accepted once the flight plan is submitted
		/// - rejectedUponSubmission: The request with the authority will be rejected once the flight plan is submitted
		public enum Status: String {
			case pending
			case accepted
			case rejected
			case acceptedUponSubmission = "accepted_upon_submission"
			case rejectedUponSubmission = "rejected_upon_submission"
		}
	}
}

/// A representation of an authoritative entity
public struct AirMapAuthority {
	/// The name of the authority
	public let name: String
}

// MARK: - JSON serialization

import ObjectMapper

extension AirMapFlightBriefing: ImmutableMappable {
	
	public init(map: Map) throws {

		let dateTransform = CustomDateFormatTransform(formatString: Config.AirMapApi.dateFormat)
		do {
			createdAt      =  try  map.value("created_at", using: dateTransform)
			rulesets       =  try  map.value("rulesets")
			status         =  try  map.value("airspace")
			authorizations = (try? map.value("authorizations")) ?? []
			validations    = (try? map.value("validations")) ?? []
		}
		catch let error {
			AirMap.logger.error(error)
			throw error
		}
	}
}

extension AirMapFlightBriefing.Ruleset: ImmutableMappable {
	
	public init(map: Map) throws {
		id    = try map.value("id")
		rules = try map.value("rules")
	}
}

extension AirMapFlightBriefing.Validation: ImmutableMappable {
	
	public init(map: Map) throws {
		do {
			status     = try map.value("status")
			feature    = try map.value("feature")
			authority  = try map.value("authority")
			message    = try map.value("message")
		}
		catch let error {
			AirMap.logger.error(error)
			throw error
		}
	}
}

extension AirMapFlightBriefing.Validation.Feature: ImmutableMappable {
	
	public init(map: Map) throws {
		do {
			code = try map.value("code")
			name = try map.value("description")
		}
		catch let error {
			AirMap.logger.error(error)
			throw error
		}
	}
}

extension AirMapAuthority: ImmutableMappable {
	
	public init(map: Map) throws {
		do {
			name = try map.value("name")
		}
		catch let error {
			AirMap.logger.error(error)
			throw error
		}
	}
}

extension AirMapFlightBriefing.Authorization: ImmutableMappable {
	
	public init(map: Map) throws {
		do {
			authority  = try map.value("authority")
			status     = try map.value("status")
			message    = try map.value("message")
		}
		catch let error {
			AirMap.logger.error(error)
			throw error
		}
	}
}
