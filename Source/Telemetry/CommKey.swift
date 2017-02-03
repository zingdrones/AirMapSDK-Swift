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
	var expiresAt = Date.distantPast
	
	func bytes() -> [UInt8] {
		
		if let data = Data(base64Encoded: key) {
			return Array(data)
		} else {
			return []
		}
	}
	
	func isValid() -> Bool {
		
		return expiresAt.lessThanDate(Date())
	}
	
	init?(map: Map) {}
}

extension CommKey: Mappable {
	
	mutating func mapping(map: Map) {
		
		key     <- map["key"]
		expiresAt = Date().addingTimeInterval(300) // 5 minute
	}
}
