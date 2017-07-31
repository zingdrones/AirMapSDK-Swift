//
//  AirMapAdvisory.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 4/8/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class AirMapAdvisory: Mappable, Hashable, Equatable {
	
	public let id: String
	public let color: AirMapStatus.StatusColor
	public let name: String
	public let lastUpdated: Date
	public let coordinate: Coordinate2D
	public let distance: Meters
	public let type: AirMapAirspaceType
	public let city: String?
	public let state: String?
	public let country: String
	public let ruleId: Int
	public let ruleSetId: String
	public let properties: AdvisoryProperties?
	public let requirements: AirMapStatusRequirements?
	
	private static let dateTransform = CustomDateFormatTransform(formatString: Config.AirMapApi.dateFormat)
	
	public required init?(map: Map) {

		do {
			id            =  try  map.value("id")
			color         =  try  map.value("color")
			lastUpdated   =  try  map.value("last_updated", using: AirMapAdvisory.dateTransform)
			distance      =  try  map.value("distance")
			type          =  try  map.value("type")
			city          =  try? map.value("city")
			state         =  try? map.value("state")
			country       =  try  map.value("country")
			ruleId        =  try  map.value("rule_id")
			ruleSetId     =  try  map.value("ruleset_id")
			requirements  =  try? map.value("requirements")
			
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
			
			let latitude  = try  map.value("latitude") as Double
			let longitude = try  map.value("longitude") as Double
			coordinate = Coordinate2D(latitude: latitude, longitude: longitude)
		}
			
		catch let error {
			print(error)
			return nil
		}
	}
	
	public var hashValue: Int {
		return id.hashValue
	}
	
	public func mapping(map: Map) {}
	
	public static func ==(lhs: AirMapAdvisory, rhs: AirMapAdvisory) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}

}

public protocol AdvisoryProperties: Mappable {}
