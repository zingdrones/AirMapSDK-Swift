//
//  AirMapFlight+MGL.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/5/16.
//
//

import Mapbox

extension AirMapFlight: MGLAnnotation {
	
	public var title: String? {
		return description
	}
	
}
