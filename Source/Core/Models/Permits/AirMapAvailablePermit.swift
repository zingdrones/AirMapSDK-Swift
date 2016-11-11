//
//  AirMapAvailablePermit.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

@objc public class AirMapAvailablePermit: NSObject {

	public private(set) var id = ""
	public private(set) var name = ""
	public private(set) var info = ""
	public private(set) var infoUrl = ""
	public private(set) var singleUse: Bool = false
	public private(set) var validForInMinutes: Int?
	public private(set) var validUntil: NSDate?
	public private(set) var customProperties = [AirMapPilotPermitCustomProperty]()
	public internal(set) var organizationId = ""
	
	internal override init() {
		super.init()
	}

	public required init?(_ map: Map) {}
	
	private static let validityFormatter: NSDateComponentsFormatter = {
		let f = NSDateComponentsFormatter()
		f.allowedUnits = [.Year, .Month, .Day, .Hour, .Minute]
		f.zeroFormattingBehavior = .DropAll
		f.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
		f.allowsFractionalUnits = false
		f.unitsStyle = .Full
		return f
	}()

	public func validityString() -> String? {
		guard let minutes = validForInMinutes else { return nil }
		return AirMapAvailablePermit.validityFormatter.stringFromTimeInterval(NSTimeInterval(minutes * 60))
	}
}

extension AirMapAvailablePermit: Mappable {

	public func mapping(map: Map) {

		let dateTransform = CustomDateFormatTransform(formatString: Config.AirMapApi.dateFormat)

		id                  <-  map["id"]
		organizationId      <-  map["organization_id"]
		name                <-  map["name"]
		info                <-  map["description"]
		infoUrl             <-  map["description_url"]
		singleUse           <-  map["single_use"]
		validForInMinutes   <-  map["valid_for"]
		validUntil          <- (map["valid_until"], dateTransform)
		customProperties    <-  map["custom_properties"]
	}

	/**
	
	Returns key value parameters
	
	- returns: [String: AnyObject]
	
	*/
	public func params() -> [String: AnyObject] {
		
		var params = [String: AnyObject]()
		params["id"] = id
		params["custom_properties"] = customProperties.toJSON()
		return params
	}
}

extension AirMapAvailablePermit {
	
	public override var hashValue: Int {
		return id.hashValue
	}
}

public func ==(lhs: AirMapAvailablePermit, rhs: AirMapAvailablePermit) -> Bool {
	return lhs.id == rhs.id
}

