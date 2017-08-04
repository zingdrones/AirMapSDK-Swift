//
//  AirMapAdvisory.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 4/8/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

/// An airspace object that interects an intended area of operation.
public struct AirMapAdvisory {
	
	/// The advisory's unique identifier
	public let id: String
	
	/// The airspace classification category
	public let type: AirMapAirspaceType
	
	/// A color representative of the advisory level
	public let color: AirMapStatus.StatusColor
	
	/// A descriptive title
	public let name: String
	
	/// The location of the advisory
	public let coordinate: Coordinate2D
	
	/// The distance from the area that generated the advisory
	public let distance: Meters
	
	/// The advisory location's city
	public let city: String?

	/// The advisory location's state/province
	public let state: String?

	/// The advisory location's country
	public let country: String
	
	/// The identifier of the rule that generated the advisory
	public let ruleId: Int

	/// The identifier of the ruleset from which the rule originated
	public let ruleSetId: String
	
	/// Additional metadata specific to the advisory type
	public let properties: AdvisoryProperties?

	/// Any requirements necessary to operate within the advisory
	public let requirements: AirMapStatusRequirements?

	/// The date and time the advisory was last updated
	public let lastUpdated: Date
}

public protocol AdvisoryProperties: Mappable {}

// MARK: - Equatable & Hashable

extension AirMapAdvisory: Equatable, Hashable {
	
	public var hashValue: Int {
		return id.hashValue
	}
	
	public static func ==(lhs: AirMapAdvisory, rhs: AirMapAdvisory) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
}

// MARK: - JSON Serialization

import ObjectMapper

extension AirMapAdvisory: ImmutableMappable {
	
	public init(map: Map) throws {
		
	let dateTransform = CustomDateFormatTransform(formatString: Config.AirMapApi.dateFormat)
		
		do {
			id            =  try  map.value("id")
			color         =  try  map.value("color")
			lastUpdated   = (try? map.value("last_updated", using: dateTransform)) ?? Date()
			distance      =  try  map.value("distance")
			type          =  try  map.value("type")
			city          =  try? map.value("city")
			state         =  try? map.value("state")
			country       =  try  map.value("country")
			ruleId        =  try  map.value("rule_id")
			ruleSetId     =  try  map.value("ruleset_id")
			requirements  =  try? map.value("requirements")

			let latitude  = try  map.value("latitude") as Double
			let longitude = try  map.value("longitude") as Double
			coordinate = Coordinate2D(latitude: latitude, longitude: longitude)

			let airspaceType = try map.value("type") as AirMapAirspaceType
			name = (try? map.value("name") as String) ?? airspaceType.title
			
			let props: [String: Any] = try map.value("properties")
			
			switch airspaceType {
			case .airport, .heliport:
				properties = AirMapStatusAdvisoryAirportProperties(JSON: props)
			case .park:
				properties = AirMapStatusAdvisoryParkProperties(JSON: props)
			case .tfr:
				properties = AirMapStatusAdvisoryTFRProperties(JSON: props)
			case .specialUse:
				properties = AirMapStatusAdvisorySpecialUseProperties(JSON: props)
			case .powerPlant:
				properties = AirMapStatusAdvisoryPowerPlantProperties(JSON: props)
			case .school:
				properties = AirMapStatusAdvisorySchoolProperties(JSON: props)
			case .controlledAirspace:
				properties = AirMapStatusAdvisoryControlledAirspaceProperties(JSON: props)
			case .wildfire:
				properties = AirMapStatusAdvisoryWildfireProperties(JSON: props)
			default:
				properties = nil
			}
		}
			
		catch let error {
			AirMap.logger.error(error)
			throw error
		}
	}
}

