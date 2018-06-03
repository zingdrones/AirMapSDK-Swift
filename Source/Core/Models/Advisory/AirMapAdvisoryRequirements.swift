//
//  AirMapAdvisoryRequirements.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

public struct AirMapAdvisoryRequirements: Codable {
	
	public let notice: Notice?
	
	public struct Notice: Codable {

		/// Notice may be provided digitally by AirMap to the controlling agency
		public let digital: Bool
		
		/// Manual notification may be provided via phone if `digital` is false
		public let phone: String?
	}
}
