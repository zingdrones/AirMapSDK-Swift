//
//  AirMap+Airspace.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/29/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

final internal class AirMapAirspace: Mappable {
	
	let id: String
	let name: String
	let type: AirMapAirspaceType
	let country: String
	let state: String?
	let city: String?
	let geometry: AirMapGeometry
	let propertyBoundary: AirMapGeometry?
	
	required init?(map: Map) {
		
		do {
			id        =  try  map.value("id")
			name      =  try  map.value("name")
			type      =  try  map.value("type")
			country   =  try  map.value("country")
			state     =  try? map.value("state")
			city      =  try? map.value("city")
			geometry  =  try  map.value("geometry", using: GeoJSONToAirMapGeometryTransform())
			propertyBoundary
				      =  try? map.value("related_geometry.property_boundary.geometry", using: GeoJSONToAirMapGeometryTransform())
		}
		catch let error {
			AirMap.logger.error(error.localizedDescription)
			return nil
		}
	}

	func mapping(map: Map) {}
}

extension AirMapAirspace: Equatable, Hashable {
	
	static func ==(lhs: AirMapAirspace, rhs: AirMapAirspace) -> Bool {
		return lhs.id == rhs.id
	}

	var hashValue: Int {
		return id.hashValue
	}
}
