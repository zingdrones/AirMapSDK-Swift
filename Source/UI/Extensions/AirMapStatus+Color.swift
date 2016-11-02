//
//  AirMapStatus+Color.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 11/2/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit

extension AirMapStatus.StatusColor {
	
	// UIColor or NSColor representation of status
	public var colorRepresentation: ColorType {
		switch self {
		case .Red:
			return .airMapRed()
		case .Yellow:
			return .airMapYellow()
		case .Green:
			return .airMapGreen()
		case .Gray:
			return .airMapGray()
		}
	}
}
