//
//  Deprecated-UI.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/25/17.
//  Copyright (c) 2016 AirMap, Inc. All rights reserved.
//

import Foundation

// Deprecated
public enum AirMapLayerType {}

// Deprecated
extension AirMapMapView {
	
	@available (*, unavailable, message: "Init map then configure with rulesets")
	public convenience init(frame: CGRect, layers: [AirMapLayerType], theme: AirMapMapTheme) {
		fatalError()
	}
	
	@available (*, unavailable, message: "Configure map using rulesets")
	public func configure(layers: [AirMapLayerType], theme: AirMapMapTheme) {}
}
