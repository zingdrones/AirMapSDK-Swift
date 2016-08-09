//
//  AirMapPilot.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

@objc public class AirMapPilot: NSObject {

	public var pilotId: String!
	public var email: String!
	public var firstName: String?
	public var lastName: String?
	public var username: String?
	public var pictureUrl: String!
	public var phone: String?
	public var phoneVerified: Bool = false
	public var emailVerified: Bool = false
	public var userMetadata = [String: AnyObject]()
	public var appMetadata = [String: AnyObject]()
	public var statistics: AirMapPilotStats!
	
	public override init() {
		super.init()
	}

	public required init?(_ map: Map) {}
	
	public typealias BuildPilotClosure = (AirMapPilot) -> Void
	
	public convenience init(build: BuildPilotClosure) {
		self.init()
		
		build(self)
	}

}

extension AirMapPilot: Mappable {
	
	public func mapping(map: Map) {
		pilotId        <-  map["id"]
		email          <-  map["email"]
		firstName      <-  map["first_name"]
		lastName       <-  map["last_name"]
		phone          <-  map["phone"]
		pictureUrl     <-  map["picture_url"]
		username       <-  map["username"]
		phoneVerified  <-  map["verification_status.phone"]
		emailVerified  <-  map["verification_status.email"]
		userMetadata   <-  map["user_metadata"]
		appMetadata    <-  map["app_metadata"]
		statistics     <-  map["statistics"]
	}

	/**
	Returns key value parameters

	- returns: [String: AnyObject]
	*/

	func params() -> [String: AnyObject] {

		var params = [String: AnyObject]()

		params["first_name"] = firstName
		params["last_name"] = lastName
		params["user_metadata"] = userMetadata
		params["app_metadata"] = appMetadata
		params["username"] = username
		params["phone"] = phone

		return params
	}

}
