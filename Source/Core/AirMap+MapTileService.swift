//
//  AirMap+MapTileService.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/6/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

typealias AirMap_MapTileService = AirMap
extension AirMap_MapTileService {

	/**

	Generates and returns map tile source url based upon Map Layers & Theme

	- parameter layers:[AirMapMapLayer] An array of AirMapMapLayer's.
	- parameter theme:[AirMapMapTheme] An AirMapMapTheme.

	- returns: NSURL?

	*/
	public class func getTileSourceUrl(layers: [AirMapLayerType], theme: AirMapMapTheme) -> NSURL? {

		guard AirMap.hasValidApiKey() else {
			logger.error(AirMap.self, "Call \(#selector(AirMap.configure(apiKey:pinCertificates:))) before sending telemetry data.")
			return nil
		}

		return mappingService.tileSourceUrl(layers, theme: theme)
	}

}
