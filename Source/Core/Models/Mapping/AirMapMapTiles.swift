//
//  AirMapMapTiles.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 2/7/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

/// Supported map themes
public enum AirMapMapTheme: String {
	
	case standard
	case dark
	case light
	case satellite
	
	public static var allThemes: [AirMapMapTheme] {
		return [.standard, .dark, .light, .satellite]
	}
}

/// The individual airspace layers available
public enum AirMapLayerType: String {
	
	case airportsCommercial             = "airports_commercial"
	case airportsCommercialPrivate      = "airports_commercial_private"
	case airportsRecreational           = "airports_recreational"
	case airportsRecreationalPrivate    = "airports_recreational_private"
	case cities                         = "cities"
	case classB                         = "class_b"
	case classC                         = "class_c"
	case classD                         = "class_d"
	case classE                         = "class_e0"  // ClassE *at the surface
	case custom                         = "custom"
	case essentialAirspace				= "class_b,class_c,class_d,class_e0"
	case hazardAreas                    = "hazard_areas"
	case heliports                      = "heliports"
	case hospitals                      = "hospitals"
	case nationalParks                  = "national_parks"
	case noaa                           = "noaa"
	case powerPlants                    = "power_plants"
	case prisons                        = "prisons"
	case prohibited                     = "sua_prohibited"
	case recreationalAreas              = "aerial_recreational_areas"
	case restricted                     = "sua_restricted"
	case schools                        = "schools"
	case tfrs                           = "tfrs"
	case universities                   = "universities"
	case fires                          = "wildfries,fires"
	case emergencies                    = "emergencies"
	
	public static let allLayerTypes = [
		airportsCommercial,
		airportsCommercialPrivate,
		airportsRecreational,
		airportsRecreationalPrivate,
		cities,
		classB,
		classC,
		classD,
		classE,
		hazardAreas,
		heliports,
		hospitals,
		nationalParks,
		noaa,
		powerPlants,
		prohibited,
		recreationalAreas,
		restricted,
		schools,
		tfrs,
		fires,
		emergencies,
		custom,
		prisons,
		universities,
	]
	
	/// A descriptive title for the layer
	public var title: String {
		
		let bundle = AirMapBundle.core
		let localized = LocalizedStrings.TileLayer.self
		
		switch self {
		case .airportsCommercial:           return localized.airports
		case .airportsRecreational:         return localized.airports
		case .airportsCommercialPrivate:    return localized.airportsPrivate
		case .airportsRecreationalPrivate:  return localized.airportsPrivate
		case .cities:                       return localized.cities
		case .classB:                       return localized.classB
		case .classC:                       return localized.classC
		case .classD:                       return localized.classD
		case .classE:                       return localized.classE
		case .custom:                       return localized.custom
		case .essentialAirspace:            return localized.essentionalAirspace
		case .hazardAreas:                  return localized.hazardAreas
		case .heliports:                    return localized.heliports
		case .hospitals:                    return localized.hospitals
		case .nationalParks:                return localized.nationalParks
		case .noaa:                         return localized.noaa
		case .powerPlants:                  return localized.powerPlants
		case .prisons:                      return localized.prisons
		case .prohibited:                   return localized.prohibited
		case .recreationalAreas:            return localized.recreationalAreas
		case .restricted:                   return localized.restricted
		case .schools:                      return localized.schools
		case .tfrs:                         return localized.tfrs
		case .universities:                 return localized.universities
		case .fires:                        return localized.fires
		case .emergencies:                  return localized.emergencies
		}
	}
	
	/// The airspace type the layer belongs to
	public var airSpaceType: AirMapAirspaceType {
		
		switch self {
		case .airportsCommercial,
		     .airportsRecreational,
		     .airportsRecreationalPrivate,
		     .airportsCommercialPrivate:
			return .airport
			
		case .heliports :
			return .heliport
			
		case .nationalParks,
		     .noaa:
			return .park
			
		case .cities:
			return .cities
			
		case .classB,
		     .classC,
		     .classD,
		     .classE,
		     .essentialAirspace:
			return .controlledAirspace
			
		case .custom:
			return .custom
			
		case .hazardAreas:
			return .hazardArea
			
		case .hospitals:
			return.hospital
			
		case .powerPlants:
			return .powerPlant
			
		case .prisons:
			return .prison
			
		case .recreationalAreas:
			return .recreationalArea
			
		case .restricted,
		     .prohibited:
			return .specialUse
			
		case .schools:
			return .school
			
		case .tfrs:
			return .tfr
			
		case .universities:
			return .university

		case .fires:
			return .fire
			
		case .emergencies:
			return .emergency
		}
	}
}

/// The airspace type/category
public enum AirMapAirspaceType: String {
	
	case airport             = "airport"
	case cities              = "cities"
	case controlledAirspace  = "controlled_airspace"
	case custom              = "custom"
	case hazardArea          = "hazard_area"
	case heliport            = "heliport"
	case hospital            = "hospital"
	case park                = "park"
	case powerPlant          = "power_plant"
	case prison              = "prisons"
	case recreationalArea    = "recreational_area"
	case school              = "school"
	case specialUse          = "special_use_airspace"
	case stadium             = "stadium"
	case tfr                 = "tfr"
	case university          = "universities"
	case wildfire            = "wildfire"
	case fire                = "fire"
	case emergency           = "emergency"
	
	public static let allAirspaceTypes: [AirMapAirspaceType] = [
		.airport,
		.cities,
		.controlledAirspace,
		.custom,
		.hazardArea,
		.heliport,
		.hospital,
		.park,
		.powerPlant,
		.prison,
		.recreationalArea,
		.school,
		.specialUse,
		.stadium,
		.tfr,
		.university,
		.wildfire,
		.fire,
		.emergency,
	]
	
	/// A descriptive title for the airspace type
	public var title: String {
		
		let bundle = AirMapBundle.core
		let localized = LocalizedStrings.AirspaceType.self

		switch self {
		case .airport:              return localized.airport
		case .cities:               return localized.city
		case .controlledAirspace:   return localized.controlledAirspace
		case .custom:               return localized.custom
		case .hazardArea:           return localized.hazardArea
		case .heliport:             return localized.heliport
		case .hospital:             return localized.hospital
		case .park:                 return localized.park
		case .powerPlant:           return localized.powerPlant
		case .prison:               return localized.prison
		case .recreationalArea:     return localized.recreationalArea
		case .school:               return localized.school
		case .specialUse:           return localized.specialUse
		case .stadium:              return localized.stadium
		case .tfr:                  return localized.tfr
		case .university:           return localized.university
		case .wildfire:             return localized.wildfire
		case .fire:                 return localized.fire
		case .emergency:            return localized.emergency
		}
	}
}

public class MappingService {
	
	/// Constructs a map tile source url for the map layers and theme provided
	///
	/// - Parameters:
	///   - layers: Layers to include in the map tile set data
	///   - theme: Map theme used to display the data
	/// - Returns: A tile source url
	public func tileSourceUrl(layers: [AirMapLayerType], theme: AirMapMapTheme) -> URL? {
		guard let apiKey = AirMap.configuration.airMapApiKey else {
			AirMap.logger.error("An API Key is required to access the AirMap Map Tile Service")
			return nil
		}
		let tiles  = layers.count == 0 ? "_-_" : layers.map { $0.rawValue }.joined(separator: ",")
		// TODO: Verify token shouldn't be the user's auth token instead of the apiKey
		let urlString = Config.AirMapApi.mapTilesUrl + "/\(tiles)?&theme=\(theme.rawValue)&apikey=\(apiKey)&token=\(apiKey)"
		
		return URL(string: urlString)
	}
	
}
