//
//  AirMapMapView.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/20/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Mapbox

class AirMapMapView: MGLMapView {
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		let bundle = NSBundle(forClass: AirMap.self)
		let image = UIImage(named: "info_icon", inBundle: bundle, compatibleWithTraitCollection: nil)!
		attributionButton.setImage(image.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
	}
	
}
