//
//  DynamicAirspaceSource.swift
//  AirMapSDK
//
//  Created by Michael Odere on 5/22/19.
//

import struct Mapbox.MGLCoordinateBounds
import class Mapbox.MGLShape
import RxSwift

public protocol DynamicAirspace {
    var shape: MGLShape { get }
	var start: Date? { get }
	var end: Date? { get }
	var authorization: Int? { get }
	var isPublished: Bool? { get }
}

public protocol DynamicAirspaceSource {
	var delegate: DynamicAirspaceSourceDelegate? { get set }
	func features(in bounds: MGLCoordinateBounds) -> [DynamicAirspace]
	func update(bounds: MGLCoordinateBounds)
//	func features(in bounds: MGLCoordinateBounds, completion: @escaping (Result<[DynamicAirspace]>) -> Void)
}

public protocol DynamicAirspaceSourceDelegate: class {
	func shouldRefreshFeautures()
}
