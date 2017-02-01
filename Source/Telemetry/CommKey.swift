//
//  CommKey.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/6/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

struct CommKey {
	
	var key: [Int]!
	var type: String!
	var expiresAt = NSDate.distantPast()
	
	func binaryKey() -> [UInt8] {
		
		let keys = key.flatMap {
			UInt8(truncatingBitPattern: $0)
		}
		return keys
	}
	
	func isValid() -> Bool {
		
		return expiresAt.lessThanDate(NSDate())
	}
	
	init?(_ map: Map) {}
}

extension CommKey: Mappable {
	
	mutating func mapping(map: Map) {
		
		key     <- map["key.data"]
		type    <- map["key.type"]
		expiresAt = NSDate().dateByAddingTimeInterval(300) // 5 minute
	}
}
