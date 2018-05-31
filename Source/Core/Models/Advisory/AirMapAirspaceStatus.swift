//
//  AirMapAirspaceStatus.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 4/10/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

public struct AirMapAirspaceStatus: Codable {

	/// A color representative of the action level of the advisory
	public let color: AirMapAdvisory.Color
	
	/// A collection of airspace advisories relevant to the area of operation
	public let advisories: [AirMapAdvisory]
}

// MARK: - Convenience

extension AirMapAirspaceStatus {
	
	/// A flag that indicates that digitial notification is supported in the area
	public var supportsDigitalNotification: Bool {
		return advisories.first(where: { $0.requirements?.notice?.digital == true }) != nil
	}
}
