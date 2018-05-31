//
//  AirMapPilot.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

open class AirMapPilot: Codable {

	open var id: AirMapPilotId!
	open var email: String!
	open var firstName: String?
	open var lastName: String?
	open var username: String?
	open var pictureUrl: String?
	open var phone: String?
	open var phoneVerified: Bool = false
	open var emailVerified: Bool = false
	open var statistics: AirMapPilotStats!

	internal init() {}
	public required init?(map: Map) {}

	public var anonymizedId: String?
}

extension AirMapPilot: Mappable {
	
	public func mapping(map: Map) {
		id             <-  map["id"]
		email          <-  map["email"]
		firstName      <-  map["first_name"]
		lastName       <-  map["last_name"]
		phone          <-  map["phone"]
		pictureUrl     <-  map["picture_url"]
		username       <-  map["username"]
		phoneVerified  <-  map["verification_status.phone"]
		emailVerified  <-  map["verification_status.email"]
		statistics     <-  map["statistics"]
		anonymizedId   <-  map["anonymized_id"]
	}

	internal func params() -> [String: Any] {

		var params = [
			"first_name":    firstName as Any,
			"last_name":     lastName as Any,
		]
		
		if let phone = phone {
			params["phone"] = phone
		}
		
		if let username = username {
			params["username"] = username
		}
		
		return params
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
