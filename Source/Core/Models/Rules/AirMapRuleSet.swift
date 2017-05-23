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
	public let jurisdictionName: String?

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
				jurisdictionName = nil
			} else {
				rules       = try map.value("rules")
				description = try map.value("description")
				layers      = []
				isDefault   = try map.value("default")
				jurisdictionName = try map.value("jurisdiction_name")
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
	
	var identifiers: String {
		return self.map { $0.id }.joined(separator: ",")
	}
}
