//
//  AirMapPilotPermitCustomProperty
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/19/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

@objc public class AirMapPilotPermitCustomProperty: NSObject {

	public var id = ""
	public var value = ""
	public var label = ""
    public var required = true

	public required init?(_ map: Map) {}

	internal override init() {
		super.init()
	}
}

extension AirMapPilotPermitCustomProperty: Mappable {

	public func mapping(map: Map) {

		id          <-  map["id"]
		value       <-  map["value"]
		label       <-	map["label"]
        required    <-  map["required"]
	}

	/**
	Returns key value parameters

	- returns: [String: AnyObject]
	*/

	func params() -> [String: AnyObject] {

		var params = [String: AnyObject]()
		params["id"] = id
		params["value"] = value
		params["label"] = label
        
		return params
	}

}
