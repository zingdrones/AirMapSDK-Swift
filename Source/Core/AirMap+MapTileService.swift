//
//  AirMap+MapTypeService.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 2/12/17.
//  Copyright © 2016-2017 AirMap, Inc. All rights reserved.
//

typealias AirMap_MapTileService = AirMap
extension AirMap_MapTileService {
	
	/// Generates and returns a style url based upon Map Theme
	///
	/// - Parameter theme: <#theme description#>
	/// - Returns: <#return value description#>
	public class func getMapStyleUrl(theme: AirMapMapTheme) -> URL? {
		return mappingService.styleUrl(theme: theme) as URL?
	}
    
    /// Generates and returns map tile source url based upon Map Layers & Theme
    ///
    /// - Parameters:
    ///   - layers: layers:[AirMapMapLayer] An array of AirMapMapLayer's.
    ///   - theme: theme:[AirMapMapTheme] An AirMapMapTheme.

	@available (*, deprecated)
    public class func getTileSourceUrl(layers: [AirMapLayerType], theme: AirMapMapTheme) -> URL? {
        return mappingService.tileSourceUrl(layers: layers, theme: theme) as URL?
    }
    
}
