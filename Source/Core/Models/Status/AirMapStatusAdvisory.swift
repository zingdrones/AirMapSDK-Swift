//
//  AirMapAdvisories.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

@objc public class AirMapStatusAdvisory: NSObject {

	public var id: String!
	public var name: String = ""
	public var type: AirMapAirspaceType?
	public var city: String = ""
	public var state: String = ""
	public var country: String = ""
	public var lastUpdated: NSDate = NSDate()
	public var color = AirMapStatus.StatusColor.Gray
	public var distance: Int = 0
	public var latitude: Double = 0
	public var longitude: Double = 0
	public var requirements: AirMapStatusRequirements?
	public var airportProperties: AirMapStatusAdvisoryAirportProperties?
	public var parkProperties: AirMapStatusAdvisoryParkProperties?
	public var powerPlantProperties: AirMapStatusAdvisoryPowerPlantProperties?
	public var specialUseProperties: AirMapStatusAdvisorySpecialUseProperties?
	public var schoolProperties: AirMapStatusAdvisorySchoolProperties?
	public var tfrProperties: AirMapStatusAdvisoryTFRProperties?
	public var controlledAirspaceProperties: AirMapStatusAdvisoryControlledAirspaceProperties?
	public var wildfireProperties : AirMapStatusAdvisoryWildfireProperties?

	public required init?(_ map: Map) {}
}

func ==(lhs: AirMapStatusAdvisory, rhs: AirMapStatusAdvisory) -> Bool {
	return lhs.id == rhs.id
}

extension AirMapStatusAdvisory: Mappable {

	public func mapping(map: Map) {

		let dateTransform = CustomDateFormatTransform(formatString: Config.AirMapApi.dateFormat)

		id              <-  map["id"]
		name            <-  map["name"]
		color           <-  map["color"]
		city            <-  map["city"]
		state           <-  map["state"]
		country         <-  map["country"]
		distance        <-  map["distance"]
		latitude        <-  map["latitude"]
		longitude       <-  map["longitude"]
		lastUpdated     <- (map["last_updated"], dateTransform)
		requirements    <-  map["requirements"]
		
		var typeString = ""; typeString <- map["type"]
		type = AirMapAirspaceType.airspaceTypeFromName(typeString)
		
		if let type = type {
			switch type {
			case .Airport:            airportProperties            <- map["properties"]
			case .Park:               parkProperties               <- map["properties"]
			case .SpecialUse:         specialUseProperties         <- map["properties"]
			case .PowerPlant:         powerPlantProperties         <- map["properties"]
			case .School:             schoolProperties             <- map["properties"]
			case .ControlledAirspace: controlledAirspaceProperties <- map["properties"]
			case .TFR:                tfrProperties                <- map["properties"]
			case .Wildfires:		  wildfireProperties           <- map["properties"]
			default:
				break
			}
		}
	}
}
