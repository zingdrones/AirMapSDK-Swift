//
//  CommKey.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/6/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import CryptoSwift

struct CommKey: Codable {
	
	var key: String
	var expiresAt = Date().addingTimeInterval(300)
	
	func bytes() -> [UInt8] {
		
		if let data = Data(base64Encoded: key) {
			return Array(data)
		} else {
			return []
		}
	}
	
	func isValid() -> Bool {
		return expiresAt < Date()
	}
}
