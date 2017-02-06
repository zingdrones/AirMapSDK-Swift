//
//  CommKey.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/6/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation
import ObjectMapper
import CryptoSwift

struct CommKey {
	
	var key: String!
	var expiresAt = NSDate.distantPast()
	
	func binaryKey() -> [UInt8] {
		
		return key.dataUsingEncoding(NSUTF8StringEncoding)?.arrayOfBytes() ?? []
	}
	
	func isValid() -> Bool {
		
		return expiresAt.lessThanDate(NSDate())
	}
	
	init?(_ map: Map) {}
}

extension CommKey: Mappable {
	
	mutating func mapping(map: Map) {
		
		key     <- map["key"]
		expiresAt = NSDate().dateByAddingTimeInterval(300) // 5 minute
	}
}
