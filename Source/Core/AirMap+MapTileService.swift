//
//  AirMap+MapTypeService.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 2/12/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

typealias AirMap_MapTileService = AirMap
extension AirMap_MapTileService {
	
	/// Generates and returns a style url based upon Map Theme
	///
	/// - Parameter theme: An AirMapMapTheme
	/// - Returns: A URL for the style
	public class func getMapStyleUrl(theme: AirMapMapTheme) -> URL? {
		return mappingService.styleUrl(theme: theme) as URL?
	}    
}
