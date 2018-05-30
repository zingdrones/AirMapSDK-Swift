//
//  EquatableHashable.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/6/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation

// INTERNAL: Extends object for Hashable, Equatable, and/or Comparable Protocol Conformance

extension AirMapRuleset: Hashable, Equatable, Comparable {
	
	internal var order: Int {
		return [.pickOne, .optional, .required].index(of: type)!
	}
	
	public var hashValue: Int {
		return id.hashValue
	}
	
	public static func ==(lhs: AirMapRuleset, rhs: AirMapRuleset) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
	
	public static func <(lhs: AirMapRuleset, rhs: AirMapRuleset) -> Bool {
		return lhs.order < rhs.order && lhs.name < rhs.name
	}
}

extension AirMapAdvisory: Equatable, Hashable {
	
	public var hashValue: Int {
		return id.hashValue
	}
	
	public static func ==(lhs: AirMapAdvisory, rhs: AirMapAdvisory) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
}

extension AirMapAdvisory.Color: Comparable {
	
	public static var all: [AirMapAdvisory.Color] {
		return [.red, .orange, .yellow, .green]
	}
	
	public var order: Int {
		return AirMapAdvisory.Color.all.index(of: self)!
	}
	
	public static func <(lhs: AirMapAdvisory.Color, rhs: AirMapAdvisory.Color) -> Bool {
		return lhs.order < rhs.order
	}
}

extension AirMapAircraft: Equatable, Hashable {
	
	public static func ==(lhs: AirMapAircraft, rhs: AirMapAircraft) -> Bool {
		return lhs.id == rhs.id
	}
	
	public var hashValue: Int {
		return id?.hashValue ?? model.id.hashValue
	}
}

extension AirMapAircraftManufacturer: Equatable, Hashable {
	
	public static func ==(lhs: AirMapAircraftManufacturer, rhs: AirMapAircraftManufacturer) -> Bool {
		return lhs.id == rhs.id
	}
	
	public var hashValue: Int {
		return id.hashValue
	}
}

extension AirMapAircraftModel: Equatable, Hashable {
	
	public static func ==(lhs: AirMapAircraftModel, rhs: AirMapAircraftModel) -> Bool {
		return lhs.id == rhs.id
	}
	
	public var hashValue: Int {
		return id.hashValue
	}
}

extension AirMapAirspace: Equatable, Hashable {
	
	static func ==(lhs: AirMapAirspace, rhs: AirMapAirspace) -> Bool {
		return lhs.id == rhs.id
	}
	
	var hashValue: Int {
		return id.hashValue
	}
}

extension AirMapFlight: Equatable, Hashable {
	
	public var hashValue: Int {
		return id?.rawValue.hashValue ?? createdAt.hashValue
	}
	
	static public func ==(lhs: AirMapFlight, rhs: AirMapFlight) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
}

extension AirMapJurisdiction: Hashable, Equatable, Comparable {
	
	public static func ==(lhs: AirMapJurisdiction, rhs: AirMapJurisdiction) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
	
	public var hashValue: Int {
		return id.hashValue
	}
	
	
	public static func <(lhs: AirMapJurisdiction, rhs: AirMapJurisdiction) -> Bool {
		return lhs.region.order < rhs.region.order
	}
}

extension AirMapJurisdiction.Region {
	
	var order: Int {
		return [.federal, .federalBackup, .federalStructureBackup, .state, .county, .city, .local].index(of: self)!
	}
}

extension AirMapFlightFeature: Hashable, Equatable {
	
	public var hashValue: Int {
		return id.hashValue
	}
	
	public static func ==(lhs: AirMapFlightFeature, rhs: AirMapFlightFeature) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
}

extension AirMapFlightFeature.Status: Comparable {
	
	var order: Int {
		return [.conflicting, .missingInfo, .informational, .notConflicting, .unevaluated].index(of: self)!
	}
	
	public static func <(lhs: AirMapFlightFeature.Status, rhs: AirMapFlightFeature.Status) -> Bool {
		return lhs.order < rhs.order
	}
}

extension AirMapMapView.RulesetConfiguration {
	static public func ==(lhs: AirMapMapView.RulesetConfiguration, rhs: AirMapMapView.RulesetConfiguration) -> Bool {
		switch (lhs, rhs) {
		case (.automatic, .automatic):
			return true

		case (let .dynamic(ids1, enabled1), let .dynamic(ids2, enabled2)):
			return ids1 == ids2 && enabled1 == enabled2

		case (let .manual(rulesets1), let .manual(rulesets2)):
			return rulesets1 == rulesets2

		default:
			break
		}

		return false
	}
}
