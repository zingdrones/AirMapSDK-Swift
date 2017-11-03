//
//  AirMapMapTiles.swift
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
	case custom              = "custom"
	case emergency           = "emergency"
	case fire                = "fire"
	case hazardArea          = "hazard_area"
	case heliport            = "heliport"
	case hospital            = "hospital"
	case laanc               = "laanc"
	case notam               = "notam"
	case park                = "park"
	case powerPlant          = "power_plant"
	case prison              = "prison"
	case recreationalArea    = "recreational_area"
	case school              = "school"
	case seaplaneBase        = "seaplane_base"
	case specialUse          = "special_use_airspace"
	case stadium             = "stadium"
	case state               = "state"
	case tfr                 = "tfr"
	case ultralightField     = "ulm_field"
	case university          = "university"
	case wildfire            = "wildfire"
	
	/// A descriptive title for the airspace type
	public var title: String {
		
		let localized = LocalizedStrings.AirspaceType.self

		switch self {
		case .airport:              return localized.airport
		case .amaField:             return localized.amaField
		case .city:                 return localized.city
		case .controlledAirspace:   return localized.controlledAirspace
		case .custom:               return localized.custom
		case .emergency:            return localized.emergency
		case .fire:                 return localized.fire
		case .hazardArea:           return localized.hazardArea
		case .heliport:             return localized.heliport
		case .hospital:             return localized.hospital
		case .laanc:                return localized.laanc
		case .notam:                return localized.notam
		case .park:                 return localized.park
		case .powerPlant:           return localized.powerPlant
		case .prison:               return localized.prison
		case .recreationalArea:     return localized.recreationalArea
		case .school:               return localized.school
		case .seaplaneBase:         return localized.seaplaneBase
		case .specialUse:           return localized.specialUse
		case .stadium:              return localized.stadium
		case .state:                return localized.state
		case .tfr:                  return localized.tfr
		case .ultralightField:      return localized.ultralightField
		case .university:           return localized.university
		case .wildfire:             return localized.wildfire
		}
	}
}
