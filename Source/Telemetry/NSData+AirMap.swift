//
//  NSData+AirMap.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 12/5/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

extension UnsignedInteger {
	
	var bytes: [UInt8] {
		var varSelf = self
		let size = MemoryLayout.size(ofValue: self)
		return withUnsafePointer(to: &varSelf) {
			$0.withMemoryRebound(to: UInt8.self, capacity: size) {
				Array(UnsafeBufferPointer(start: $0, count: size))
			}
		}
	}

}


