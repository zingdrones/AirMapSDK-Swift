//
//  NSData+AirMap.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 12/5/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation
import CryptoSwift

extension NSData {
	
	func AES256CBCEncrypt(key key: [UInt8], iv: [UInt8]) -> NSData? {
	
		let count = length / sizeof(UInt8)
		var input = [UInt8](count: count, repeatedValue: 0)
		
		getBytes(&input, length: count * sizeof(UInt8))
		
		do {
			let encrypted: [UInt8] = try AES(key: key, iv: iv, blockMode: .CBC).encrypt(input)
			return NSData(bytes: encrypted)
		} catch {
			return nil
		}
	}

	func AES256CBCDecrypt(key key: [UInt8], iv: [UInt8]) -> NSData? {
		
		let count = length / sizeof(UInt8)
		var input = [UInt8](count: count, repeatedValue: 0)
		
		getBytes(&input, length: count * sizeof(UInt8))
		
		do {
			let decrypted: [UInt8] = try AES(key: key, iv: iv, blockMode: .CBC).decrypt(input)
			return NSData(bytes: decrypted)
		} catch {
			return nil
		}
	}

}

extension UInt8 {
	var data: NSData {
		var varSelf = self
		return NSData(bytes: &varSelf, length: sizeofValue(self))
	}
}

extension UInt16 {
	var data: NSData {
		var varSelf = self.bigEndian
		return NSData(bytes: &varSelf, length: sizeofValue(self))
	}
}

extension UInt32 {
	var data: NSData {
		var varSelf = self.bigEndian
		return NSData(bytes: &varSelf, length: sizeofValue(self))
	}
}

extension NSUUID {
	var data: NSData {
		var uuid = [UInt8](count: 16, repeatedValue: 0)
		self.getUUIDBytes(&uuid)
		return NSData(bytes: &uuid, length: 16)
	}
}

extension String {
	var utf8Data: NSData {
		return dataUsingEncoding(NSUTF8StringEncoding) ?? NSData()
	}
}

extension Array where Element: NSData {
	func data() -> NSData {
		return reduce(NSMutableData()) { total, nextData in
			total.appendData(nextData)
			return total
		}
	}
}
