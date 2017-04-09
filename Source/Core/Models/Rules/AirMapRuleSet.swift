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
}

public class AirMapRuleSet: Mappable, Equatable, Comparable, Hashable {
	
	public let id: String
	public let name: String
	public let shortName: String
	public let type: AirMapRuleSetType
	public let layers: [String]
	public let isDefault: Bool
	public let rules: [AirMapRule]
	public let summary: String
	
	internal var order: Int {
		return [.pickOne, .optional, .required].index(of: self.type)!
	}

	public var hashValue: Int {
		return id.hashValue
	}
	
	public required init?(map: Map) {
		do {
			id        = try map.value("id")
			name      = try map.value("name")
			shortName = try map.value("short_name")
			type      = try map.value("type")
			
			if let context = map.context as? DataOrigin, context == .tileService {
				rules   = []
				summary = ""
				layers  = try map.value("layers")
				isDefault = try map.value("default")
			} else {
				rules     = try map.value("rules")
				summary   = try map.value("summary")
				layers    = []
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

public func ==(lhs: AirMapRuleSet, rhs: AirMapRuleSet) -> Bool {
	return lhs.hashValue == rhs.hashValue
}

public func <(lhs: AirMapRuleSet, rhs: AirMapRuleSet) -> Bool {
	
	return lhs.order < rhs.order
}

extension Sequence where Iterator.Element == AirMapRuleSet {
	
	var identifiers: String {
		return self.map { $0.id }.joined(separator: ",")
	}
}
