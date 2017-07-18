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
	case classA                         = "class_a"
	case classB                         = "class_b"
	case classC                         = "class_c"
	case classD                         = "class_d"
	case classE                         = "class_e0"  // "0" = At the surface
	case classF                         = "class_f"
	case classG                         = "class_g"
	case custom                         = "custom"
	case emergencies                    = "emergencies"
	case essentialAirspace              = "class_b,class_c,class_d,class_e0"
	case fires                          = "fires"
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
	case wildfires                      = "wildfires"
	
	public static let allLayerTypes = [
		airportsCommercial,
		airportsCommercialPrivate,
		airportsRecreational,
		airportsRecreationalPrivate,
		cities,
		classA,
		classB,
		classC,
		classD,
		classE,
		classF,
		classG,
		custom,
		emergencies,
		fires,
		hazardAreas,
		heliports,
		hospitals,
		nationalParks,
		noaa,
		powerPlants,
		prisons,
		prohibited,
		recreationalAreas,
		restricted,
		schools,
		tfrs,
		universities,
		wildfires,
	]
	
	/// A descriptive title for the layer
	public var title: String {
		
		let localized = LocalizedStrings.TileLayer.self
		
		switch self {
		case .airportsCommercial:           return localized.airports
		case .airportsRecreational:         return localized.airports
		case .airportsCommercialPrivate:    return localized.airportsPrivate
		case .airportsRecreationalPrivate:  return localized.airportsPrivate
		case .cities:                       return localized.cities
		case .classA:                       return localized.classA
		case .classB:                       return localized.classB
		case .classC:                       return localized.classC
		case .classD:                       return localized.classD
		case .classE:                       return localized.classE
		case .classF:                       return localized.classF
		case .classG:                       return localized.classG
		case .custom:                       return localized.custom
		case .emergencies:                  return localized.emergencies
		case .essentialAirspace:            return localized.essentionalAirspace
		case .fires:                        return localized.fires
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
		case .wildfires:                    return localized.wildfires
		}
	}
	
	/// The airspace type the layer belongs to
	public var airspaceType: AirMapAirspaceType {
		
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
			return .city
			
		case .classA,
		     .classB,
		     .classC,
		     .classD,
		     .classE,
		     .classF,
		     .classG,
		     .essentialAirspace:
			return .controlledAirspace
			
		case .custom:
			return .custom
			
		case .emergencies:
			return .emergency
			
		case .fires:
			return .fire
			
		case .hazardAreas:
			return .hazardArea
			
		case .hospitals:
			return.hospital
			
		case .powerPlants:
			return .powerPlant
			
		case .prisons:
			return .prison
			
		case .prohibited,
		     .restricted:
			return .specialUse
			
		case .recreationalAreas:
			return .recreationalArea
			
		case .schools:
			return .school
			
		case .tfrs:
			return .tfr
			
		case .universities:
			return .university
			
		case .wildfires:
			return .wildfire
		}
	}
}

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
	case notam               = "notam"
	case park                = "park"
	case powerPlant          = "power_plant"
	case prison              = "prison"
	case recreationalArea    = "recreational_area"
	case school              = "school"
	case seaplaneBase        = "seaplane_base"
	case specialUse          = "special_use_airspace"
	case stadium             = "stadium"
	case tfr                 = "tfr"
	case university          = "university"
	case wildfire            = "wildfire"
	
	public static let allAirspaceTypes: [AirMapAirspaceType] = [
		.airport,
		.amaField,
		.city,
		.controlledAirspace,
		.custom,
		.emergency,
		.fire,
		.hazardArea,
		.heliport,
		.hospital,
		.notam,
		.park,
		.powerPlant,
		.prison,
		.recreationalArea,
		.school,
		.seaplaneBase,
		.specialUse,
		.stadium,
		.tfr,
		.university,
		.wildfire,
	]
	
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
		case .notam:                return localized.notam
		case .park:                 return localized.park
		case .powerPlant:           return localized.powerPlant
		case .prison:               return localized.prison
		case .recreationalArea:     return localized.recreationalArea
		case .school:               return localized.school
		case .seaplaneBase:         return localized.seaplaneBase
		case .specialUse:           return localized.specialUse
		case .stadium:              return localized.stadium
		case .tfr:                  return localized.tfr
		case .university:           return localized.university
		case .wildfire:             return localized.wildfire
		}
	}
}

public class MappingService {
	
	/// Constructs a styleUrl based on the AirMap Theme
	///
	/// - Parameters:
	///   - theme: Map theme used to display the data
	/// - Returns: A style url
	public func styleUrl(theme: AirMapMapTheme) -> URL? {
		guard let _ = AirMap.configuration.airMapApiKey else {
			AirMap.logger.error("An API Key is required to access the AirMap Map Service")
			return nil
		}
		let urlString = "https://cdn.airmap.com/static/map-styles/v0.6/\(theme.rawValue).json"
		return URL(string: urlString)
	}
	
	/// Constructs a map tile source url for the map layers and theme provided
	///
	/// - Parameters:
	///   - layers: Layers to include in the map tile set data
	///   - theme: Map theme used to display the data
	/// - Returns: A tile source url
	@available (*, deprecated)
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
