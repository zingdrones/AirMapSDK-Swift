//
//  AirMapIdentifier.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 12/13/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

public typealias StringId<T> = Id<String, T>
public typealias IntegerId<T> = Id<Int, T>

// Type-safe aliases for identifiers specific to AirMap objects
public typealias AirMapAdvisoryId                = StringId<AirMapAdvisory>
public typealias AirMapAircraftId                = StringId<AirMapAircraft>
public typealias AirMapAircraftManufacturerId    = StringId<AirMapAircraftManufacturer>
public typealias AirMapAircraftModelId           = StringId<AirMapAircraftModel>
public typealias AirMapAirspaceId                = StringId<AirMapAirspace>
public typealias AirMapAuthorityId               = StringId<AirMapAuthority>
public typealias AirMapFlightId                  = StringId<AirMapFlight>
public typealias AirMapFlightPlanId              = StringId<AirMapFlightPlan>
public typealias AirMapFlightFeatureId           = StringId<AirMapFlightFeature>
public typealias AirMapPilotId                   = StringId<AirMapPilot>
public typealias AirMapRulesetId                 = StringId<AirMapRuleset>

public typealias AirMapJurisdictionId            = IntegerId<AirMapJurisdiction>
public typealias AirMapRuleId                    = IntegerId<AirMapJurisdiction>

public protocol AirMapIdentifierType: RawRepresentable, CustomStringConvertible, Codable {
	associatedtype RawValue
	associatedtype Entity
}

public struct Id<RawValue: Codable & Hashable & CustomStringConvertible, Entity>: AirMapIdentifierType {

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

extension Id: Hashable, Equatable {

	public var hashValue: Int {
		return rawValue.hashValue
	}

	public static func ==(lhs: Id, rhs: Id) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
}

extension Id: CustomStringConvertible {

	public var description: String {
		return rawValue.description
	}
}
