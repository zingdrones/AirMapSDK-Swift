//
//  DynamicAirspaceSource.swift
//  AirMapSDK
//
//  Created by Michael Odere on 5/22/19.
//

import struct Mapbox.MGLCoordinateBounds
import RxSwift

public protocol DynamicAirspace {
	var id: String { get }
    var geometry: AirMapGeometry { get }
	var expiration: Date? { get }
}

public protocol DynamicAirspaceSource {
	var delegate: DynamicAirspaceSourceDelegate? { get set }
	func features(in bounds: MGLCoordinateBounds) -> [DynamicAirspace]
//	func features(in bounds: MGLCoordinateBounds, completion: @escaping (Result<[DynamicAirspace]>) -> Void)
}

public protocol DynamicAirspaceSourceDelegate: class {
	func shouldRefreshFeautures()
}
