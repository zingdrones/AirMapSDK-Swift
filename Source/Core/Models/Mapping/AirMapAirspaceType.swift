//
//  AirMapAirspaceType.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 2/7/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

/// The airspace type/category
public enum AirMapAirspaceType: String {
	
	case airport             = "airport"
	case amaField            = "ama_field"
	case city                = "city"
	case controlledAirspace  = "controlled_airspace"
	case country             = "country"
	case county              = "county"
	case custom              = "custom"
	case embassy             = "embassy"
	case emergency           = "emergency"
	case federalBuilding     = "federal_building"
	case fir                 = "fir"
	case fire                = "fire"
	case gliderport          = "gliderport"
	case hazardArea          = "hazard_area"
	case heliport            = "heliport"
	case highway             = "highway"
	case hospital            = "hospital"
	case industrialProperty  = "industrial_property"
	case japanBase           = "jpn_base"
	case militaryProperty    = "military_property"
	case notam               = "notam"
	case park                = "park"
	case policeStation       = "police_station"
	case powerline           = "powerline"
	case powerPlant          = "power_plant"
	case prison              = "prison"
	case railway             = "railway"
	case recreationalArea    = "recreational_area"
	case residentialProperty = "residential_property"
	case school              = "school"
	case seaplaneBase        = "seaplane_base"
	case specialUse          = "special_use_airspace"
	case stadium             = "stadium"
	case state               = "state"
	case subprefecture       = "subprefecture"
	case supercity           = "supercity"
	case tfr                 = "tfr"
	case ultralightField     = "ulm_field"
	case university          = "university"
	case waterway            = "waterway"
	case wildfire            = "wildfire"

	// Catchall for new airspace types not yet supported by this version of the SDK but returned in advisory or map tile data
	case unclassified        = "unclassified"
	
	/// A descriptive title for the airspace type
	public var title: String {
		
		let localized = LocalizedStrings.AirspaceType.self
		
		switch self {
		case .airport:              return localized.airport
		case .amaField:             return localized.amaField
		case .city:                 return localized.city
		case .controlledAirspace:   return localized.controlledAirspace
		case .country:              return localized.country
		case .county:               return localized.county
		case .custom:               return localized.custom
		case .embassy:              return localized.embassy
		case .emergency:            return localized.emergency
		case .federalBuilding:      return localized.federalBuilding
		case .fire:                 return localized.fire
		case .fir:                  return localized.fir
		case .gliderport:           return localized.gliderport
		case .hazardArea:           return localized.hazardArea
		case .heliport:             return localized.heliport
		case .highway:              return localized.highway
		case .industrialProperty:   return localized.industrialProperty
		case .hospital:             return localized.hospital
		case .japanBase:            return localized.japanBase
		case .militaryProperty:     return localized.militaryProperty
		case .notam:                return localized.notam
		case .park:                 return localized.park
		case .policeStation:        return localized.policeStation
		case .powerline:            return localized.powerline
		case .powerPlant:           return localized.powerPlant
		case .prison:               return localized.prison
		case .railway:              return localized.railway
		case .recreationalArea:     return localized.recreationalArea
		case .residentialProperty:  return localized.residentialProperty
		case .school:               return localized.school
		case .seaplaneBase:         return localized.seaplaneBase
		case .specialUse:           return localized.specialUse
		case .stadium:              return localized.stadium
		case .state:                return localized.state
		case .subprefecture:        return localized.subprefecture
		case .supercity:            return localized.supercity
		case .tfr:                  return localized.tfr
		case .ultralightField:      return localized.ultralightField
		case .unclassified:         return localized.unclassified
		case .university:           return localized.university
		case .waterway:             return localized.waterway
		case .wildfire:             return localized.wildfire
		}
	}
}
