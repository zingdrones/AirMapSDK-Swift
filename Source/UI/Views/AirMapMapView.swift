//
//  AirMapMapView.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/20/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Mapbox

open class AirMapMapView: MGLMapView {
	
	open static let defaultLayers: [AirMapLayerType] = [.essentialAirspace, .tfrs, .fires, .emergencies]
	open static let defaultTheme: AirMapMapTheme = .light
	
	public convenience init(frame: CGRect, layers: [AirMapLayerType], theme: AirMapMapTheme) {
		self.init(frame: frame)
		
		setupMapView()
		configure(layers: layers, theme: theme)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		setupMapView()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		setupMapView()
	}
	
	open func configure(layers: [AirMapLayerType], theme: AirMapMapTheme) {
		styleURL = AirMap.mappingService.tileSourceUrl(layers: layers, theme: theme)
	}
	
	fileprivate func setupMapView() {
		
		guard let mapboxAccessToken = AirMap.configuration.mapboxAccessToken else {
			fatalError("A Mapbox access token is required to use the AirMap SDK UI components.")
		}
		
		MGLAccountManager.setAccessToken(mapboxAccessToken)
		
		let image = UIImage(named: "info_icon", in: AirMapBundle.ui, compatibleWith: nil)!
		attributionButton.setImage(image.withRenderingMode(.alwaysOriginal), for: UIControlState())
		
		configure(layers: AirMapMapView.defaultLayers, theme: AirMapMapView.defaultTheme)
	}
	
}
