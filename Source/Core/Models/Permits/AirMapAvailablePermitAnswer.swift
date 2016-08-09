//
//  AirMapAvailablePermitAnswer.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

@objc public class AirMapAvailablePermitAnswer: NSObject {
	
	public var id = ""
	public var text = ""
	public var nextQuestionId: String?
	public var permitId: String?
	public var message = ""

	internal override init() {
		super.init()
	}

	public required init?(_ map: Map) {}
}

extension AirMapAvailablePermitAnswer: Mappable {
	
	public func mapping(map: Map) {
		id              <-  map["id"]
		text            <-  map["text"]
		nextQuestionId  <-  map["next_question_id"]
		permitId        <-  map["permit_id"]
		message         <-  map["message"]
	}
}
