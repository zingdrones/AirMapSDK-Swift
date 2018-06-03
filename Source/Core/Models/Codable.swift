//
//  Codable.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 5/31/18.
//

extension Coordinate2D: Codable {

	private enum CodingKeys: CodingKey {
		case latitude
		case longitude
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(latitude, forKey: .latitude)
		try container.encode(longitude, forKey: .longitude)
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		latitude = try container.decode(Double.self, forKey: .latitude)
		longitude = try container.decode(Double.self, forKey: .longitude)
	}
}

// MARK: - Codable

extension AirMapAdvisory {

	private enum CodingKeys: CodingKey {
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
