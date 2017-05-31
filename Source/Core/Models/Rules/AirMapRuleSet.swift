//
//  AirMapRuleSet.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 3/24/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public enum DataOrigin: MapContext {
	case tileService
	case airMapApi
}

public class AirMapRuleSet: Mappable {
	
	public enum SelectionType: String {
		case optional
		case pickOne = "pick1"
		case required
		
		public var name: String {
			switch self {
			case .optional:
				return "Optional"
			case .pickOne:
				return "Pick One"
			case .required:
				return "Required"
			}
		}
	}
	
	public let id: String
	public let name: String
	public let shortName: String
	public let type: SelectionType
	public let layers: [String]
	public let isDefault: Bool
	public let rules: [AirMapRule]
	public let description: String
	
	public internal(set) var jurisdictionName: String!
	public internal(set) var jurisdictionRegion: AirMapJurisdiction.Region!

	internal var order: Int {
		return [.pickOne, .optional, .required].index(of: type)!
	}

	public var hashValue: Int {
		return id.hashValue
	}
	
	enum MappingError: Error {
		case unknownType
	}

	public required init?(map: Map) {
		do {
			id        = try map.value("id")
			name      = try map.value("name")
			shortName = try map.value("short_name")
			type      = try map.value("selection_type")
			
			if let context = map.context as? DataOrigin, context == .tileService {
				rules       = []
				description = try map.value("short_description")
				layers      = try map.value("layers") as [String]
                isDefault   = try map.value("default")
			} else {
				rules       = try map.value("rules")
				description = try map.value("description")
				layers      = []
				isDefault   = try map.value("default")

				jurisdictionName   = try? map.value("jurisdiction_name")
				jurisdictionRegion = try? map.value("region")
			}
		}
		catch let error {
			print(error)
			return nil
		}
	}
	
	public func mapping(map: Map) {}
}

extension AirMapRuleSet: Hashable, Equatable, Comparable {
	
	public static func ==(lhs: AirMapRuleSet, rhs: AirMapRuleSet) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
	
	public static func <(lhs: AirMapRuleSet, rhs: AirMapRuleSet) -> Bool {
		
		return lhs.order < rhs.order && lhs.name < rhs.name
	}
}

extension Sequence where Iterator.Element == AirMapRuleSet {
	
	public var identifiers: String {
		return self.map { $0.id }.joined(separator: ",")
	}
	
	public var requiredRuleSets: [AirMapRuleSet] {
		return filter { $0.type == .required }
	}
	
	public var pickOneRuleSets: [AirMapRuleSet] {
		return filter { $0.type == .pickOne }
	}
	
	public var defaultPickOneRuleSet: AirMapRuleSet? {
		return pickOneRuleSets.first(where: { $0.isDefault }) ?? pickOneRuleSets.first
	}
	
	public var optionalRuleSets: [AirMapRuleSet] {
		return filter { $0.type == .optional }
	}
	
	public var jurisdictions: [AirMapJurisdiction] {
		return self
			.reduce([String: String]()) { (dict, next) -> [String: String] in
				var dict = dict
				dict[next.jurisdictionName] = next.jurisdictionName
				return dict
			}
			.keys
			.map { (name) -> AirMapJurisdiction in
				let rs = filter({ $0.jurisdictionName == name })
				let j = rs.first!
				return AirMapJurisdiction(name: j.jurisdictionName, region: j.jurisdictionRegion, ruleSets: rs)
		}
		
	}
}


