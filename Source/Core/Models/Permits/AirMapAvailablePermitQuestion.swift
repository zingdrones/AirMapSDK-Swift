//
//  AirMapAvailablePermitQuestion.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

@objc public class AirMapAvailablePermitQuestion: NSObject {
	
	public var id = ""
	public var text = ""
	public var answers = [AirMapAvailablePermitAnswer]()
	
	internal override init() {
		super.init()
	}
	
	public required init?(_ map: Map) {}
}

extension AirMapAvailablePermitQuestion: Mappable {
	
	public func mapping(map: Map) {
		id        <-  map["id"]
		text      <-  map["text"]
		answers   <-  map["answers"]
	}

}
