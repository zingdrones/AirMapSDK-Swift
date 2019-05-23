//
//  DynamicAirspaceSource.swift
//  AirMapSDK
//
//  Created by Michael Odere on 5/22/19.
//

import Foundation
import Mapbox

public protocol DynamicAirspaceSource {
	var delegate: DynamicAirspaceSourceDelegate? { get set }
	func features(in bounds: MGLCoordinateBounds) -> [Any]
}

public protocol DynamicAirspaceSourceDelegate {
	func shouldRefreshSource()
}
