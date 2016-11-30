//
//  AirMapPilotPermit.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/19/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

@objc public class AirMapPilotPermit: NSObject {

	public enum PermitStatus: String {
		case Accepted	= "accepted"
		case Rejected	= "rejected"
		case Pending	= "pending"
		case Expired	= "expired"
	}

	public var id = ""
	public var permitId = ""
	public var status: PermitStatus?
	public var createdAt: NSDate = NSDate()
	public var updatedAt: NSDate!
	public var expiresAt: NSDate!
	public var customProperties = [AirMapPilotPermitCustomProperty]()
	public var permitDetails: AirMapPilotPermitShortDetails!
	public var organization: AirMapOrganization?

	public required init?(_ map: Map) {}

	internal override init() {
		super.init()
	}
	
	override public var hashValue: Int {
		return id.hashValue
	}
	
	override public func isEqual(object: AnyObject?) -> Bool {
		if let permit = object as? AirMapPilotPermit {
			return permit == self
		} else {
			return false
		}
	}

}

public func ==(lhs: AirMapPilotPermit, rhs: AirMapPilotPermit) -> Bool {
	if lhs.id.isEmpty || rhs.id.isEmpty {
		return lhs.permitId == rhs.permitId
	} else {
		return lhs.id == rhs.id
	}
}

extension AirMapPilotPermit: Mappable {

	public func mapping(map: Map) {

		let dateTransform = CustomDateFormatTransform(formatString: Config.AirMapApi.dateFormat)

		id					<-  map["id"]
		permitId			<-  map["permit.id"]
		organization		<-  map["organization"]
		createdAt			<- (map["created_at"], dateTransform)
		updatedAt			<- (map["updated_at"], dateTransform)
		expiresAt			<- (map["expiration"], dateTransform)
		customProperties	<-  map["custom_properties"]
		permitDetails		<-  map["permit"]
		status				<-	map["status"]
	}

	/**
	Returns key value parameters

	- returns: [String: AnyObject]
	*/

	func params() -> [String: AnyObject] {

		var params = [String: AnyObject]()
		params["id"] = id
		params["custom_properties"] = customProperties.toJSON()

		return params
	}

}
