//
//  AirMapPilotPermitCustomProperty
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/19/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapPilotPermitCustomProperty {

	public var id = ""
	public var value = ""
	public var label = ""
	public var type = ""
    public var required = true

	internal init() {}
	public required init?(map: Map) {}
}

extension AirMapPilotPermitCustomProperty: Mappable {

	public func mapping(map: Map) {

		id        <-  map["id"]
		type      <-  map["type"]
		value     <-  map["value"]
		label     <-  map["label"]
        required  <-  map["required"]
	}
	
	func params() -> [String: String] {

		return [
			"id":    id,
			"value": value,
			"label": label
		]
	}

}
