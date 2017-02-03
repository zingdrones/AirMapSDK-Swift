//
//  AirMap+Airspace.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/29/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

final class AirMapAirspace: Equatable, Hashable {
	
	public fileprivate(set) var id: String!
	public fileprivate(set) var name: String!
	public fileprivate(set) var type: AirMapAirspaceType!
	public fileprivate(set) var country: String!
	public fileprivate(set) var state: String!
	public fileprivate(set) var city: String!
	public fileprivate(set) var geometry: AirMapGeometry!
	public fileprivate(set) var propertyBoundary: AirMapGeometry!
	public fileprivate(set) var rules = [AirMapAirspaceRule]()
	
	public required init?(map: Map) {}
	
	public var hashValue: Int {
		return id.hashValue
	}
}

extension AirMapAirspace: Mappable {
	
	public func mapping(map: Map) {
		id               <-  map["id"]
		name             <-  map["name"]
		country          <-  map["country"]
		state            <-  map["state"]
		city             <-  map["city"]
		geometry         <- (map["geometry"], GeoJSONToAirMapGeometryTransform())
		rules            <-  map["rules"]
		propertyBoundary <- (map["related_geometry.property_boundary.geometry"], GeoJSONToAirMapGeometryTransform())
		type             <-  map["type"]
	}
}

internal func ==(lhs: AirMapAirspace, rhs: AirMapAirspace) -> Bool {
	return lhs.id == rhs.id
}
