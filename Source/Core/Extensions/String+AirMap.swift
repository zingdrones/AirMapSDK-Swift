//
//  String+AirMap.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/2/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

extension String {
	
	var urlEncoded: String {
		return stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()) ?? self
	}
	
}
