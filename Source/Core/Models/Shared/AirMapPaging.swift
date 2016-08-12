//
//  Paging.swift
//
//  Created by Rocky Demoff on 7/19/16
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapPaging: NSObject {

	public var total: Int?
	public var limit: Int = 100
	public var offset: Int?
	public var prev: String?
	public var next: String?

	required public init?(_ map: Map) {}
}

extension AirMapPaging: Mappable {

	public func mapping(map: Map) {

		total   <-  map["total"]
		limit   <-  map["limit"]
		offset  <-  map["offset"]
		prev    <-  map["prev"]
		next    <-  map["next"]
	}
}
