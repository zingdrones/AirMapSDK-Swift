//
//  AirMapPermitDecisionFlow.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

@objc public class AirMapPermitDecisionFlow: NSObject {
	
	public var firstQuestionId: String!
	public var questions = [AirMapAvailablePermitQuestion]()
	
	internal override init() {
		super.init()
	}
	
	public required init?(_ map: Map) {}
}

extension AirMapPermitDecisionFlow: Mappable {
	
	public func mapping(map: Map) {
		firstQuestionId  <-  map["first_question_id"]
		questions        <-  map["questions"]
	}
}
