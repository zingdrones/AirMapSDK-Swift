//
//  AirMapAvailablePermit.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

@objc public class AirMapAvailablePermit: NSObject {

	public var id = ""
	public var organizationId = ""
	public var name = ""
	public var info = ""
	public var infoUrl = ""
	public var singleUse: Bool = false
	public var isApplicable: Bool = false
	public var validForInMinutes: Int?
	public var validUntil: NSDate?
	public var customProperties = [AirMapPilotPermitCustomProperty]()
	
	internal override init() {
		super.init()
	}

	public required init?(_ map: Map) {}
	
	private static let validityFormatter: NSDateComponentsFormatter = {
		$0.allowedUnits = [.Year, .Month, .Day, .Hour, .Minute]
		$0.zeroFormattingBehavior = .DropAll
		$0.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
		$0.allowsFractionalUnits = false
		$0.unitsStyle = .Full
		return $0
	}(NSDateComponentsFormatter())

	public func validityString() -> String? {
		guard let minutes = validForInMinutes else { return nil }
		return AirMapAvailablePermit.validityFormatter.stringFromTimeInterval(NSTimeInterval(minutes * 60))
	}
}

extension AirMapAvailablePermit: Mappable {

	public func mapping(map: Map) {

		let dateTransform = CustomDateFormatTransform(formatString: Config.AirMapApi.dateFormat)

		id					<-  map["id"]
		organizationId		<-  map["organization_id"]
		name				<-	map["name"]
		info				<-	map["description"]
		infoUrl				<-	map["description_url"]
		singleUse			<-	map["single_use"]
		isApplicable        <-  map["applicable"]
		validForInMinutes	<-	map["valid_for"]
		validUntil			<- (map["valid_until"], dateTransform)
		customProperties	<-	map["custom_properties"]
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

