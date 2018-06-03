//
//  AirMapAdvisory.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 4/8/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

/// An airspace object that intersects with area of operation.
public struct AirMapAdvisory: Codable {
	
	/// The advisory's unique identifier
	public let id: AirMapAdvisoryId
	
	/// The airspace classification type
	public let type: AirMapAirspaceType
	
	/// A color representative of the advisory level
	public let color: Color
	
	/// A descriptive title
	public let name: String

	/// The location of the advisory
	public let coordinate: Coordinate2D

	/// The advisory location's city
	public let city: String?

	/// The advisory location's state/province
	public let state: String?

	/// The advisory location's country
	public let country: String?
	
	/// The identifier of the rule that generated the advisory
	public let ruleId: AirMapRuleId

	/// The identifier of the ruleset from which the rule originated
	public let rulesetId: AirMapRulesetId

	/// Additional metadata specific to the advisory type
	public let properties: Properties?

	/// Any requirements necessary to operate within the advisory
	public let requirements: AirMapAdvisoryRequirements?

	/// The date and time the advisory was last updated
	public let lastUpdated: Date
	
	/// A color representative of the level of advisory
	public enum Color: String, Codable {
		/// Restricted
		case red
		/// Action required
		case orange
		/// Caution
		case yellow
		/// Informational
		case green
	}

	/// Airport advisory properties
	public struct AirportProperties: Properties, HasOptionalPhone, HasOptionalURL, HasOptionalDescription, Codable {
		public let identifier: String?
		public let phone: String?
		public let tower: Bool?
		public let type: String?
		public let longestRunway: Meters?
		public let instrumentProcedure: Bool?
		public let url: URL?
		public let description: String?
		public let icao: String?
	}

	/// AMA Field advisory properties
	public struct AMAFieldProperties: Properties, HasOptionalURL {
		public let url: URL?
		public let siteLocation: String?
		public let contactName: String?
		public let contactPhone: String?
		public let contactEmail: String?
	}

	/// Controlled Airspace advisory properties
	public struct ControlledAirspaceProperties: Properties {
		public let type: String?
		public let isLaancProvider: Bool?
		public let supportsAuthorization: Bool?
	}

	/// City advisory properties
	public struct CityProperties: Properties, HasOptionalURL, HasOptionalDescription {
		public let url: URL?
		public let description: String?
	}

	/// Custom Airspace advisory properties
	public struct CustomProperties: Properties, HasOptionalURL, HasOptionalDescription {
		public let url: URL?
		public let description: String?
	}

	/// Emergency advisory properties
	public struct EmergencyProperties: Properties {
		public let dateEffective: Date?
		public let type: String?
	}

	/// Fire advisory properties
	public struct FireProperties: Properties {
		public let dateEffective: Date?
	}

	/// Heliport advisory properties
	public struct HeliportProperties: Properties, HasOptionalPhone {
		public let identifier: String?
		public let paved: Bool?
		public let phone: String?
		public let tower: Bool?
		public let use: String?
		public let instrumentProcedure: Bool?
		public let icao: String?
	}

	/// Park advisory properties
	public struct ParkProperties: Properties, HasOptionalURL {
		public let type: String?
		public let url: URL?
	}

	/// Power Plant advisory properties
	public struct PowerPlantProperties: Properties {
		public let tech: String?
		public let generatorType: String?
		public let output: Int?
	}

	/// School advisory properties
	public struct SchoolProperties: Properties {
		public let students: Int?
	}

	/// Special Use Airspace advisory properties
	public struct SpecialUseProperties: Properties, HasOptionalDescription {
		public let description: String?
	}

	/// TFR advisory advisory properties
	public struct TFRProperties: Properties, HasOptionalURL {
		public let url: URL?
		public let effectStart: Date?
		public let effectiveEnd: Date?
		public let type: String?
		public let sport: String?
		public let venue: String?
	}

	/// University advisory properties
	public struct UniversityProperties: Properties, HasOptionalURL, HasOptionalDescription {
		public let url: URL?
		public let description: String?
	}

	/// Wildfire advisory properties
	public struct WildfireProperties: Properties {
		public let dateEffective: Date?
		public let size: Hectares?
	}
}

public protocol Properties: Codable {}

// FIXME: Move these HasOptional… protocols out of SDK
public protocol HasOptionalPhone {
	var phone: String? { get }
}

public protocol HasOptionalURL {
	var url: URL? { get }
}

public protocol HasOptionalDescription {
	var description: String? { get }
}

// MARK: - CustomStringConvertible

extension AirMapAdvisory.Color: CustomStringConvertible {
	
	public var description: String {
		
		let localized = LocalizedStrings.Status.self
		
		switch self {
		case .red:     return localized.redDescription
		case .orange:  return localized.orangeDescription
		case .yellow:  return localized.yellowDescription
		case .green:   return localized.greenDescription
		}
	}
}
