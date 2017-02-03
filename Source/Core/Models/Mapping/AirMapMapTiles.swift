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
	
	case airportsCommercial          = "airports_commercial"
	case airportsCommercialPrivate   = "airports_commercial_private"
	case airportsRecreational        = "airports_recreational"
	case airportsRecreationalPrivate = "airports_recreational_private"
	case cities = "cities"
	case classB = "class_b"
	case classC = "class_c"
	case classD = "class_d"
	case classE = "class_e0"  // ClassE *at the surface
	case custom = "custom"
	case essentialAirspace = "class_b,class_c,class_d,class_e0"
	case hazardAreas       = "hazard_areas"
	case heliports         = "heliports"
	case hospitals         = "hospitals"
	case nationalParks     = "national_parks"
	case noaa              = "noaa"
	case powerPlants       = "power_plants"
	case prisons           = "prisons"
	case prohibited        = "sua_prohibited"
	case recreationalAreas = "aerial_recreational_areas"
	case restricted        = "sua_restricted"
	case schools           = "schools"
	case tfrs              = "tfrs"
	case universities      = "universities"
	case wildfires         = "wildfires"
	
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
		wildfires,
		custom,
		prisons,
		universities,
	]
	
	/// A descriptive title for the layer
	public var title: String {
		
		switch self {
		case .airportsCommercial:
			return "Airport"
		case .airportsRecreational:
			return	"Airport"
		case .airportsCommercialPrivate:
			return "Private Airport"
		case .airportsRecreationalPrivate:
			return	"Private Airport"
		case .cities:
			return "Cities"
		case .classB:
			return "Class B Controlled Airspace"
		case .classC:
			return "Class C Controlled Airspace"
		case .classD:
			return "Class D Controlled Airspace"
		case .classE:
			return "Class E Controlled Airspace"  // ClassE *at the surface
		case .custom:
			return "Custom"
		case .essentialAirspace:
			return "Controlled Airspace (B, C, D & E)"
		case .hazardAreas:
			return "Hazard Areas"
		case .heliports:
			return "Heliport"
		case .hospitals:
			return "Hospital"
		case .nationalParks:
			return "National Park"
		case .noaa:
			return "NOAA Marine Protection Area"
		case .powerPlants:
			return "Power Plant"
		case .prisons:
			return "Prisons"
		case .prohibited:
			return "Prohibited Airspace"
		case .recreationalAreas:
			return "Aerial Recreational Areas"
		case .restricted:
			return "Restricted Airspace"
		case .schools:
			return "School"
		case .tfrs:
			return "Temporary Flight Restriction"
		case .universities:
			return "Universities"
		case .wildfires:
			return "Wildfires"
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

		case .wildfires:
			return .wildfires
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
	case wildfires           = "wildfire"
	
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
		.wildfires,
	]
	
	/// A descriptive title for the airspace type
	public var title: String {
		
		switch self {
		case .airport:
			return "Airport"
		case .cities:
			return "Cities"
		case .controlledAirspace:
			return "Controlled Airspace"
		case .custom:
			return "Custom"
		case .hazardArea:
			return "Hazard Area"
		case .heliport:
			return "Heliport"
		case .hospital:
			return "Hospital"
		case .park:
			return "National Park"
		case .powerPlant:
			return "Power Plant"
		case .prison:
			return "Prison"
		case .recreationalArea:
			return "Aerial Recreational Area"
		case .school:
			return "School"
		case .specialUse:
			return "Special Use Airspace"
		case .stadium:
			return "Stadium"
		case .tfr:
			return "Temporary Flight Restriction"
		case .university:
			return "University"
		case .wildfires:
			return "Wildfire"
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
