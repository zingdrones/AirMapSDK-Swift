//
//  Paging.swift
//
//  Created by Rocky Demoff on 7/19/16
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

open class AirMapPaging {

	open var total: Int?
	open var limit: Int = 100
	open var offset: Int?
	open var prev: String?
	open var next: String?

	required public init?(map: Map) {}
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
