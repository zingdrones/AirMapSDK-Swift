//
//  AirMapIdentifier.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 12/13/17.
//

import Foundation

public protocol AirMapIdentifier: RawRepresentable, CustomStringConvertible, Hashable where RawValue: Hashable & Equatable {}

extension AirMapIdentifier {
	
	public var hashValue: Int {
		return rawValue.hashValue
	}
	
	public static func ==(lhs: Self, rhs: Self) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
}

public protocol AirMapStringIdentifierType: ExpressibleByStringLiteral, AirMapIdentifier where RawValue == String {}

public struct AirMapStringIdentifier<Object>: AirMapStringIdentifierType {
	
	public typealias RawValue = String
	public typealias StringLiteralType = String

	public let rawValue: RawValue
	
	public init(rawValue: RawValue) {
		self.rawValue = rawValue
	}
	
	public init(stringLiteral: StringLiteralType) {
		self.rawValue = stringLiteral
	}

    public var description: String {
        return rawValue.description
    }
}

public protocol AirMapIntegerIdentifierType: ExpressibleByIntegerLiteral, AirMapIdentifier where RawValue == Int {}

public struct AirMapIntegerIdentifier<Object>: AirMapIntegerIdentifierType {
	
	public typealias RawValue = Int
	public typealias IntegerLiteralType = Int
	
	public let rawValue: RawValue
	
	public init(rawValue: RawValue) {
		self.rawValue = rawValue
	}
	
	public init(integerLiteral: IntegerLiteralType) {
		self.rawValue = integerLiteral
	}

    public var description: String {
        return rawValue.description
    }
}

// Type-safe aliases for string identifiers specific to AirMap objects
public typealias AirMapAdvisoryId              = AirMapStringIdentifier<AirMapAdvisory>
public typealias AirMapAircraftId              = AirMapStringIdentifier<AirMapAircraft>
public typealias AirMapAircraftManufacturerId  = AirMapStringIdentifier<AirMapAircraftManufacturer>
public typealias AirMapAircraftModelId         = AirMapStringIdentifier<AirMapAircraftModel>
public typealias AirMapFlightId                = AirMapStringIdentifier<AirMapFlight>
public typealias AirMapAuthorityId             = AirMapStringIdentifier<AirMapAuthority>
public typealias AirMapRulesetId               = AirMapStringIdentifier<AirMapRuleset>
public typealias AirMapFlightFeatureId         = AirMapStringIdentifier<AirMapFlightFeature>
public typealias AirMapPilotId                 = AirMapStringIdentifier<AirMapPilot>
public typealias AirMapFlightPlanId            = AirMapStringIdentifier<AirMapFlightPlan>

internal typealias AirMapAirspaceId            = AirMapStringIdentifier<AirMapAirspace>

// Type-safe aliases for integer identifiers specific to AirMap objects
public typealias AirMapJurisdictionId = AirMapIntegerIdentifier<AirMapJurisdiction>
