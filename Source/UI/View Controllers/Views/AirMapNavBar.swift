//
//  AirMapNavBar.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/22/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

open class AirMapNavBar: UINavigationBar {
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}

	fileprivate func setup() {
		isTranslucent = false
		barStyle = .black
		tintColor = .white
		barTintColor = .airMapDarkGray
	}
	
}
