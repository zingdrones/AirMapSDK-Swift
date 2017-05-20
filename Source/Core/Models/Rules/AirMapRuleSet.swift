//
//  AirMapRuleSet.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 3/24/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public enum DataOrigin: MapContext {
	case tileService
	case airMapApi
}

public enum AirMapRuleSetType: String {
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

public class AirMapRuleSet: Mappable {
	
	public let id: String
	public let name: String
	public let shortName: String
	public let type: AirMapRuleSetType
	public let layers: [String]
	public let isDefault: Bool
	public let rules: [AirMapRule]
	public let description: String
	
	internal var order: Int {
		return [.pickOne, .optional, .required].index(of: self.type)!
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
			
			if let context = map.context as? DataOrigin, context == .tileService {
                type        = try map.value("type")
				rules       = []
				description = "N/A"
				layers      = try map.value("layers") as [String]
                isDefault   = try map.value("default")

			} else {
                type        = try map.value("selection_type")
				rules       = try map.value("rules")
				description = try map.value("description")
				layers      = []
				// FIXME: Remove once API returns default
				isDefault = false
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
