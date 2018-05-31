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
		public let use: String?
		public let longestRunway: Meters?
		public let instrumentProcedure: Bool?
		public let url: URL?
		public let description: String?
		public let icao: String?
	}

	/// AMA field properties
	public struct AMAFieldProperties: Properties, HasOptionalURL {
		public let url: URL?
		public let siteLocation: String?
		public let contactName: String?
		public let contactPhone: String?
		public let contactEmail: String?
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

	/// Controlled Airspace advisory properties
	public struct ControlledAirspaceProperties: Properties {
		public let type: String?
		public let isLaancProvider: Bool?
		public let supportsAuthorization: Bool?
	}

	/// City properties
	public struct CityProperties: Properties, HasOptionalURL, HasOptionalDescription {
		public let url: URL?
		public let description: String?
	}

	/// Custom airspace properties
	public struct CustomProperties: Properties, HasOptionalURL, HasOptionalDescription {
		public let url: URL?
		public let description: String?
	}

	/// Emergency advisory properties
	public struct EmergencyProperties: Properties {
		public let effective: Date?
		public let type: String?
	}

	/// Fire advisory properties
	public struct FireProperties: Properties {
		public let effective: Date?
	}

	/// Park advisory properties
	public struct ParkProperties: Properties, HasOptionalURL {
		public let type: String?
		public let url: URL?
	}

	/// Power Plant advisory properties
	public struct PowerPlantProperties: Properties {
		public let technology: String?
		public let generatorType: String?
		public let output: Int?
	}

	/// School advisory properties
	public struct SchoolProperties: Properties {
		public let numberOfStudents: Int?
	}

	/// Special Use advisory properties
	public struct SpecialUseProperties: Properties, HasOptionalDescription {
		public let description: String?
	}

	/// TFR advisory properties
	public struct TFRProperties: Properties, HasOptionalURL {
		public let url: URL?
		public let startTime: Date?
		public let endTime: Date?
		public let type: String?
		public let sport: String?
		public let venue: String?
	}

	/// University properties
	public struct UniversityProperties: Properties, HasOptionalURL, HasOptionalDescription {
		public let url: URL?
		public let description: String?
	}

	/// Wildfire advisory properties
	public struct WildfireProperties: Properties {
		public let effective: Date?
		public let size: Hectares?
	}
}

public protocol Properties: Codable {}

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

// MARK: - Codable

extension AirMapAdvisory {

	enum CodingKeys: String, CodingKey {
		case id
		case type
		case color
		case name
		case latitude
		case longitude
		case city
		case state
		case country
		case ruleId
		case rulesetId
		case properties
		case requirements
		case lastUpdated
	}

	public init(from decoder: Decoder) throws {

		let v = try decoder.container(keyedBy: CodingKeys.self)

		id = try v.decode(AirMapAdvisoryId.self, forKey: .id)
		type = try v.decode(AirMapAirspaceType.self, forKey: .type)
		color = try v.decode(Color.self, forKey: .color)
		name = try v.decode(String.self, forKey: .name)
		city = try v.decodeIfPresent(String.self, forKey: .city)
		state = try v.decodeIfPresent(String.self, forKey: .state)
		country = try v.decodeIfPresent(String.self, forKey: .country)
		ruleId = try v.decode(AirMapRuleId.self, forKey: .ruleId)
		rulesetId = try v.decode(AirMapRulesetId.self, forKey: .rulesetId)
		requirements = try v.decodeIfPresent(AirMapAdvisoryRequirements.self, forKey: .requirements)
		lastUpdated = try v.decode(Date.self, forKey: .lastUpdated)

		let latitude = try v.decode(Double.self, forKey: .latitude)
		let longitude = try v.decode(Double.self, forKey: .latitude)
		coordinate = Coordinate2D(latitude: latitude, longitude: longitude)

		switch type {
		case .airport:
			properties = try v.decodeIfPresent(AirportProperties.self, forKey: .properties)
		case .heliport:
			properties = try v.decodeIfPresent(HeliportProperties.self, forKey: .properties)
		case .controlledAirspace:
			properties = try v.decodeIfPresent(ControlledAirspaceProperties.self, forKey: .properties)
		case .city:
			properties = try v.decodeIfPresent(CityProperties.self, forKey: .properties)
		case .custom:
			properties = try v.decodeIfPresent(CustomProperties.self, forKey: .properties)
		case .emergency:
			properties = try v.decodeIfPresent(EmergencyProperties.self, forKey: .properties)
		case .fire:
			properties = try v.decodeIfPresent(FireProperties.self, forKey: .properties)
		case .park:
			properties = try v.decodeIfPresent(ParkProperties.self, forKey: .properties)
		case .powerPlant:
			properties = try v.decodeIfPresent(PowerPlantProperties.self, forKey: .properties)
		case .school:
			properties = try v.decodeIfPresent(SchoolProperties.self, forKey: .properties)
		case .specialUse:
			properties = try v.decodeIfPresent(SpecialUseProperties.self, forKey: .properties)
		case .tfr:
			properties = try v.decodeIfPresent(TFRProperties.self, forKey: .properties)
		case .university:
			properties = try v.decodeIfPresent(UniversityProperties.self, forKey: .properties)
		case .wildfire:
			properties = try v.decodeIfPresent(WildfireProperties.self, forKey: .properties)
		default:
			properties = nil
		}
	}

	public func encode(to encoder: Encoder) throws {

		var c = encoder.container(keyedBy: CodingKeys.self)

		try c.encode(id, forKey: .id)
		try c.encode(type, forKey: .type)
		try c.encode(color, forKey: .color)
		try c.encode(name, forKey: .name)
		try c.encode(coordinate.latitude, forKey: .latitude)
		try c.encode(coordinate.longitude, forKey: .longitude)
		try c.encodeIfPresent(city, forKey: .city)
		try c.encodeIfPresent(state, forKey: .state)
		try c.encodeIfPresent(country, forKey: .country)
		try c.encode(ruleId, forKey: .ruleId)
		try c.encode(rulesetId, forKey: .rulesetId)
	}
}
