//
//  AirMapAdvisories.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

@objc public class AirMapStatusAdvisory: NSObject {

	public private(set) var id: String!
	public private(set) var name: String = ""
	public private(set) var type: AirMapAirspaceType?
	public private(set) var city: String = ""
	public private(set) var state: String = ""
	public private(set) var country: String = ""
	public private(set) var lastUpdated: NSDate = NSDate()
	public private(set) var color = AirMapStatus.StatusColor.Gray
	public private(set) var distance: Int = 0
	public private(set) var latitude: Double = 0
	public private(set) var longitude: Double = 0
	public private(set) var requirements: AirMapStatusRequirements?
	public private(set) var airportProperties: AirMapStatusAdvisoryAirportProperties?
	public private(set) var parkProperties: AirMapStatusAdvisoryParkProperties?
	public private(set) var powerPlantProperties: AirMapStatusAdvisoryPowerPlantProperties?
	public private(set) var specialUseProperties: AirMapStatusAdvisorySpecialUseProperties?
	public private(set) var schoolProperties: AirMapStatusAdvisorySchoolProperties?
	public private(set) var tfrProperties: AirMapStatusAdvisoryTFRProperties?
	public private(set) var controlledAirspaceProperties: AirMapStatusAdvisoryControlledAirspaceProperties?
	public private(set) var wildfireProperties : AirMapStatusAdvisoryWildfireProperties?
	public private(set) var availablePermits = [AirMapAvailablePermit]()
	public internal(set) var organization: AirMapOrganization?
	
	internal private(set) var organizationId: String?

	public required init?(_ map: Map) {}
	
	override public var hashValue: Int {
		return id.hashValue
	}
	
	public override func isEqual(object: AnyObject?) -> Bool {
		if let object = object as? AirMapStatusAdvisory {
			return object.id == self.id
		} else {
			return false
		}
	}
}

func ==(lhs: AirMapStatusAdvisory, rhs: AirMapStatusAdvisory) -> Bool {
	return lhs.id == rhs.id
}

extension AirMapStatusAdvisory: Mappable {

	public func mapping(map: Map) {

		let dateTransform = CustomDateFormatTransform(formatString: Config.AirMapApi.dateFormat)

		id               <-  map["id"]
		organizationId   <-  map["organization_id"]
		name             <-  map["name"]
		color            <-  map["color"]
		city             <-  map["city"]
		state            <-  map["state"]
		country          <-  map["country"]
		distance         <-  map["distance"]
		latitude         <-  map["latitude"]
		longitude        <-  map["longitude"]
		lastUpdated      <- (map["last_updated"], dateTransform)
		requirements     <-  map["requirements"]
		availablePermits <-  map["available_permits"]
		
		var typeString = ""; typeString <- map["type"]
		type = AirMapAirspaceType.airspaceTypeFromName(typeString)
		
		if let type = type {
			switch type {
			case .Airport, .Heliport: airportProperties            <- map["properties"]
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
