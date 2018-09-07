//
//  AirMapPilot.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/13/16.
/*
Copyright 2018 AirMap, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
//

import ObjectMapper

open class AirMapPilot {

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

	fileprivate var _userMetadata = [String: Any]()
	fileprivate var _appMetadata = [String: Any]()
	
	open func appMetadata() -> [String: Any] {
		return _appMetadata
	}
	
	open func setAppMetadata(value: Any?, forKey: String) {
		_appMetadata[forKey] = value
	}

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
		_userMetadata  <-  map["user_metadata"]
		_appMetadata   <-  map["app_metadata"]
		statistics     <-  map["statistics"]
		anonymizedId   <-  map["anonymized_id"]
	}

	internal func params() -> [String: Any] {

		var params = [
			"first_name":    firstName as Any,
			"last_name":     lastName as Any,
			"user_metadata": _userMetadata,
			"app_metadata":  _appMetadata,
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
		case (.some(let firstName), nil):
			return firstName
		case (nil, .some(let lastName)):
			return lastName
		case (nil, nil):
			return nil
		}
	}
}
