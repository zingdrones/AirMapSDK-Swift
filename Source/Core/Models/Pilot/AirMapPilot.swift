//
//  AirMapPilot.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

public final class AirMapPilot: Codable {

	public internal(set) var id: AirMapPilotId?

	public var email: String?
	public var firstName: String?
	public var lastName: String?
	public var username: String?
	public var phone: String?

	public internal(set) var pictureUrl: String?
	public internal(set) var phoneVerified: Bool
	public internal(set) var emailVerified: Bool
	public internal(set) var statistics: AirMapPilotStats?
	public internal(set) var anonymizedId: String?

	public init(from decoder: Decoder) throws {

		let container = try decoder.container(keyedBy: CodingKeys.self)

		id            = try container.decode(AirMapPilotId.self, forKey: .id)
		email         = try container.decode(String.self, forKey: .email)
		firstName     = try container.decode(String.self, forKey: .firstName)
		lastName      = try container.decode(String.self, forKey: .lastName)
		username      = try container.decode(String.self, forKey: .username)
		pictureUrl    = try container.decode(String.self, forKey: .pictureUrl)
		phone         = try container.decode(String.self, forKey: .phone)
		anonymizedId  = try container.decode(String.self, forKey: .anonymizedId)
		statistics    = try container.decode(AirMapPilotStats.self, forKey: .statistics)

		let verificationStatus = try container.decode(VerificationStatus.self, forKey: .verificationStatus)
		phoneVerified = verificationStatus.phone
		emailVerified = verificationStatus.email
	}
}

extension AirMapPilot {

	/// Convenience getter that returns a user's localized full name
	public var fullName: String? {
		
		switch (firstName, lastName) {
		case (.some(let givenName), .some(let familyName)):
			return String(format: LocalizedStrings.PilotProfile.fullNameFormat, givenName, familyName)
		case (.some(let givenName), nil):
			return givenName
		case (nil, .some(let familyName)):
			return familyName
		case (nil, nil):
			return nil
		}
	}
}
