//
//  Deprecated-UI.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 5/17/18.
//  Copyright © 2018 AirMap, Inc. All rights reserved.
//

import UIKit

extension AirMapMapView {

	public enum AirMapLayerType {}
	public enum AirMapMapTheme {}

	@available (*, unavailable, renamed: "rulesetConfiguration")
	public var configuration: RulesetConfiguration {
		get { return rulesetConfiguration }
		set { rulesetConfiguration = newValue}
	}

	@available (*, unavailable, message: "Init map then configure with rulesets")
	public convenience init(frame: CGRect, layers: [AirMapLayerType], theme: AirMapMapTheme) {
		fatalError()
	}

	@available (*, unavailable, message: "Configure map using rulesets")
	public func configure(layers: [AirMapLayerType], theme: AirMapMapTheme) {}
}
