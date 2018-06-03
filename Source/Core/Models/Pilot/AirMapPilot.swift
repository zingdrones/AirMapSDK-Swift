//
//  AirMapPilot.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

open class AirMapPilot: Codable {

	public internal(set) var id: AirMapPilotId?
	public var email: String?
	public var firstName: String?
	public var lastName: String?
	public var username: String?
	public var pictureUrl: String?
	public var phone: String?
	public var phoneVerified: Bool = false
	public var emailVerified: Bool = false
	public var statistics: AirMapPilotStats?

	internal init() {}
	public required init?(map: Map) {}

	public var anonymizedId: String?
}

extension AirMapPilot: Mappable {
	
	public func mapping(map: Map) {
		phoneVerified  <-  map["verification_status.phone"]
		emailVerified  <-  map["verification_status.email"]
	}
}

extension AirMapPilot {

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
