//
//  AirMapIdentifier.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 12/13/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

public typealias AirMapStringIdentifier<T>  = AirMapIdentifier<String, T>
public typealias AirMapIntegerIdentifier<T> = AirMapIdentifier<Int, T>

// Type-safe aliases for identifiers specific to AirMap objects
public typealias AirMapAdvisoryId                = AirMapStringIdentifier<AirMapAdvisory>
public typealias AirMapAircraftId                = AirMapStringIdentifier<AirMapAircraft>
public typealias AirMapAircraftManufacturerId    = AirMapStringIdentifier<AirMapAircraftManufacturer>
public typealias AirMapAircraftModelId           = AirMapStringIdentifier<AirMapAircraftModel>
public typealias AirMapAirspaceId                = AirMapStringIdentifier<AirMapAirspace>
public typealias AirMapAuthorityId               = AirMapStringIdentifier<AirMapAuthority>
public typealias AirMapFlightId                  = AirMapStringIdentifier<AirMapFlight>
public typealias AirMapFlightPlanId              = AirMapStringIdentifier<AirMapFlightPlan>
public typealias AirMapFlightFeatureId           = AirMapStringIdentifier<AirMapFlightFeature>
public typealias AirMapPilotId                   = AirMapStringIdentifier<AirMapPilot>
public typealias AirMapRulesetId                 = AirMapStringIdentifier<AirMapRuleset>

public typealias AirMapJurisdictionId            = AirMapIntegerIdentifier<AirMapJurisdiction>
public typealias AirMapRuleId                    = AirMapIntegerIdentifier<AirMapJurisdiction>

public protocol AirMapIdentifierType: RawRepresentable, CustomStringConvertible, Codable {
	associatedtype RawValue
	associatedtype Object
}

public struct AirMapIdentifier<RawValue: Codable & Hashable & CustomStringConvertible, Object>: AirMapIdentifierType {

	public let rawValue: RawValue

	public init(rawValue: RawValue) {
		self.rawValue = rawValue
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(rawValue)
	}

	public init(from decoder: Decoder) throws {
		rawValue = try decoder.singleValueContainer().decode(RawValue.self)
	}
}

extension AirMapIdentifier: Hashable, Equatable {

	public var hashValue: Int {
		return rawValue.hashValue
	}

	public static func ==(lhs: AirMapIdentifier, rhs: AirMapIdentifier) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
}

extension AirMapIdentifier: CustomStringConvertible {

	public var description: String {
		return rawValue.description
	}
}
