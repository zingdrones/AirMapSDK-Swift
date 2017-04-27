//
//  AirMapAdvisories.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapStatusAdvisory {

	public fileprivate(set) var id: String!
	public fileprivate(set) var name: String = ""
	public fileprivate(set) var type: AirMapAirspaceType!
	public fileprivate(set) var city: String = ""
	public fileprivate(set) var state: String = ""
	public fileprivate(set) var country: String = ""
	public fileprivate(set) var lastUpdated: Date = Date()
	public fileprivate(set) var color = AirMapStatus.StatusColor.gray
	public fileprivate(set) var distance: Meters = 0
	public fileprivate(set) var latitude: Double = 0
	public fileprivate(set) var longitude: Double = 0
	public fileprivate(set) var requirements: AirMapStatusRequirements?
	public fileprivate(set) var airportProperties: AirMapStatusAdvisoryAirportProperties?
	public fileprivate(set) var parkProperties: AirMapStatusAdvisoryParkProperties?
	public fileprivate(set) var powerPlantProperties: AirMapStatusAdvisoryPowerPlantProperties?
	public fileprivate(set) var specialUseProperties: AirMapStatusAdvisorySpecialUseProperties?
	public fileprivate(set) var schoolProperties: AirMapStatusAdvisorySchoolProperties?
	public fileprivate(set) var tfrProperties: AirMapStatusAdvisoryTFRProperties?
	public fileprivate(set) var controlledAirspaceProperties: AirMapStatusAdvisoryControlledAirspaceProperties?
	public fileprivate(set) var wildfireProperties : AirMapStatusAdvisoryWildfireProperties?
	public fileprivate(set) var availablePermits = [AirMapAvailablePermit]()
	public internal(set) var organization: AirMapOrganization?
	
	internal fileprivate(set) var organizationId: String?

	public required init?(map: Map) {
		guard (try? map.value("type") as AirMapAirspaceType) != nil else {
			AirMap.logger.warning("Unexpected advisory type", map.JSON["type"] ?? "")
			return nil
		}
	}
	
	public func isEqual(_ object: Any?) -> Bool {
		if let object = object as? AirMapStatusAdvisory {
			return object.id == self.id
		} else {
			return false
		}
	}
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
		type             <-  map["type"]
		
		if let type = type {
			switch type {
			case .airport, .heliport: airportProperties            <- map["properties"]
			case .park:               parkProperties               <- map["properties"]
			case .specialUse:         specialUseProperties         <- map["properties"]
			case .powerPlant:         powerPlantProperties         <- map["properties"]
			case .school:             schoolProperties             <- map["properties"]
			case .controlledAirspace: controlledAirspaceProperties <- map["properties"]
			case .tfr:                tfrProperties                <- map["properties"]
			case .wildfire:           wildfireProperties           <- map["properties"]
			default:
				break
			}
		}
	}
}

extension AirMapStatusAdvisory: Hashable, Equatable {
	
	public static func ==(lhs: AirMapStatusAdvisory, rhs: AirMapStatusAdvisory) -> Bool {
		return lhs.id == rhs.id
	}

	open var hashValue: Int {
		return id.hashValue
	}
}
