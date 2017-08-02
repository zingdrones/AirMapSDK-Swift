//
//  AirMapRuleSet.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 3/24/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

/// A logical grouping of rules under a give jurisdiction
public struct AirMapRuleSet {
	
	/// An unique identifier
	public let id: String
	
	/// A descriptive title
	public let name: String
	
	/// A short descriptive title
	public let shortName: String
	
	/// A type that denotes the selection requirement
	public let type: SelectionType
	
	/// The identifiers for the airspace types represented by the ruleset
	public let airspaceTypeIds: [String]
	
	/// True if this ruleset is of type pick-one, and it should be selected by default
	public let isDefault: Bool
	
	/// The rules grouped under this ruleset
	public let rules: [AirMapRule]

	/// A long-form textual description
	public let description: String
	
	/// The identifier for the jurisdiction the ruleset belongs to
	public fileprivate(set) var jurisdictionId: Int!

	/// The name of the jurisdiction the ruleset belongs to
	public fileprivate(set) var jurisdictionName: String!

	/// The region type of the jurisdiction the ruleset belongs to
	public fileprivate(set) var jurisdictionRegion: AirMapJurisdiction.Region!

	/// A type that dictates how the ruleset should be used
	///
	/// - optional: Selection is optional and at the operator's discretion
	/// - pickOne: The ruleset is part of a group of rulesets where the operator must select one and only one ruleset from the group. Rulesets have only one grouping of pick-one rulesets.
	/// - required: The ruleset must always be selected
	public enum SelectionType: String {
		case optional
		case pickOne = "pick1"
		case required

		/// A descriptive title
		public var name: String {
			switch self {
			case .optional:  return "Optional"
			case .pickOne:   return "Pick One"
			case .required:  return "Required"
			}
		}
	}
	
	internal mutating func setJurisdiction(_ jurisdiction: AirMapJurisdiction) {
		jurisdictionId = jurisdiction.id
		jurisdictionName = jurisdiction.name
		jurisdictionRegion = jurisdiction.region
	}
}

extension AirMapRuleSet: Hashable, Equatable, Comparable {
	
	internal var order: Int {
		return [.pickOne, .optional, .required].index(of: type)!
	}

	public var hashValue: Int {
		return id.hashValue
	}

	public static func ==(lhs: AirMapRuleSet, rhs: AirMapRuleSet) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
	
	public static func <(lhs: AirMapRuleSet, rhs: AirMapRuleSet) -> Bool {
		return lhs.order < rhs.order && lhs.name < rhs.name
	}
}

// MARK: - Convenience

extension Sequence where Iterator.Element == AirMapRuleSet {
	
	/// A comma-separated list of ruleset identifiers
	public var identifiers: String {
		return self.map { $0.id }.joined(separator: ",")
	}
	
	/// A filtered list of all required rulesets
	public var requiredRuleSets: [AirMapRuleSet] {
		return filter { $0.type == .required }
	}
	
	/// A filtered list of all pick-one rulesets
	public var pickOneRuleSets: [AirMapRuleSet] {
		return filter { $0.type == .pickOne }
	}
	
	/// A filtered list of all default rulesets
	public var defaultPickOneRuleSet: AirMapRuleSet? {
		return pickOneRuleSets.first(where: { $0.isDefault }) ?? pickOneRuleSets.first
	}
	
	/// A filtered list of all optional rulesets
	public var optionalRuleSets: [AirMapRuleSet] {
		return filter { $0.type == .optional }
	}
	
	/// A list of jurisdictions derived from a list of rulesets
	public var jurisdictions: [AirMapJurisdiction] {
		return self
			.reduce([Int: Int]()) { (dict, next) -> [Int: Int] in
				var dict = dict
				dict[next.jurisdictionId] = next.jurisdictionId
				return dict
			}
			.keys
			.map { (id) -> AirMapJurisdiction in
				let rs = filter({ $0.jurisdictionId == id })
				let j = rs.first!
				return AirMapJurisdiction(id: j.jurisdictionId, name: j.jurisdictionName, region: j.jurisdictionRegion, ruleSets: rs)
		}
	}
}

// MARK: - JSON Serialization

import ObjectMapper

extension AirMapRuleSet: ImmutableMappable {
	
	/// The origin from where the JSON originated
	///
	/// - tileService: data from tile service metadata
	/// - airMapApi: data from the ruleset API
	public enum Origin: MapContext {
		case tileService
		case airMapApi
	}
	
	public init(map: Map) throws {

		id        =  try  map.value("id")
		name      =  try  map.value("name")
		shortName = (try? map.value("short_name")) ?? "?"
		type      =  try  map.value("selection_type")
		isDefault =  try  map.value("default")
		
		switch map.context as? Origin ?? .airMapApi {
			
		case .airMapApi:
			rules              = try map.value("rules")
			description        = try map.value("description")
			airspaceTypeIds    = try map.value("airspace_types") as [String]

			jurisdictionId     = try? map.value("jurisdiction.id")
			jurisdictionName   = try? map.value("jurisdiction.name")
			jurisdictionRegion = try? map.value("jurisdiction.region")
			
		case .tileService:
			rules       = []
			description = (try? map.value("short_description")) ?? ""
			airspaceTypeIds      = try map.value("layers") as [String]
		}
	}
}
