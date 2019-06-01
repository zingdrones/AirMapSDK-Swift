//
//  AirMapAuthorization.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 5/31/19.
//  Copyright 2019 AirMap, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

/// A representation of an authoritative entity
public struct AirMapAuthority {

	/// The identifier of the authority
	public let id: AirMapAuthorityId

	/// The name of the authority
	public let name: String
}

/// A representation of an authorization or permission required to perform a flight in a given jurisdiction by an authoritive entity
public struct AirMapAuthorization {

	/// The authoritive entity issuing the authorization
	public let authority: AirMapAuthority

	/// The description of the authorization
	public let description: String

	/// The authorization status of the flight plan
	public let status: Status

	/// A textual message describing the current status of the request
	public let message: String

	/// A reference number for the authorization
	public let referenceNumber: String?

	/// An enumeration of possible authorization states
	///
	/// - pending: The request with the authority has been made and a response is pending
	/// - accepted: The request with the authority has been accepted
	/// - rejected: The request with the authority has been rejected
	/// - notRequested: The request with the authority has not been requested
	/// - authorizedUponSubmission: The request with the authority will be accepted once the flight plan is submitted
	/// - rejectedUponSubmission: The request with the authority will be rejected once the flight plan is submitted
	/// - manualAuthorization: The request with the authority will be reviewed manually sometime after the flight plan is submitted
	public enum Status: String {
		case pending
		case accepted
		case rejected
		case notRequested = "not_requested"
		case rejectedUponSubmission = "rejected_upon_submission"
		case authorizedUponSubmission = "authorized_upon_submission"
		case manualAuthorization = "manual_authorization"
		case cancelled = "cancelled"

		public var description: String {
			let localized = LocalizedStrings.Authorization.self
			switch self {
			case .pending:
				return localized.pending
			case .accepted:
				return localized.accepted
			case .rejected:
				return localized.rejected
			case .notRequested:
				return localized.notRequested
			case .rejectedUponSubmission:
				return localized.rejectedUponSubmission
			case .authorizedUponSubmission:
				return localized.authorizedUponSubmission
			case .manualAuthorization:
				return localized.manualAuthorization
			case .cancelled:
				return localized.cancelled
			}
		}
	}
}
