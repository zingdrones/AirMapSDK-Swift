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
		
		let bundle = AirMapBundle.main
		
		switch self {
		case .airportsCommercial, .airportsRecreational:
			return NSLocalizedString("TILE_LAYER_AIRPORTS", bundle: bundle, value: "Airports", comment: "Name for map layer Commercial Airports")
		case .airportsCommercialPrivate, .airportsRecreationalPrivate:
			return NSLocalizedString("TILE_LAYER_PRIVATE_AIRPORTS", bundle: bundle, value: "Private Airports", comment: "Name for map layer Private Airports")
		case .cities:
			return NSLocalizedString("TILE_LAYER_CITIES", bundle: bundle, value: "Cities", comment: "Name for map layer Cities")
		case .classB:
			return NSLocalizedString("TILE_LAYER_CLASS_B", bundle: bundle, value: "Class B Controlled Airspace", comment: "Name for map layer Class B Airspace")
		case .classC:
			return NSLocalizedString("TILE_LAYER_CLASS_C", bundle: bundle, value: "Class C Controlled Airspace", comment: "Name for map layer Class C Airspace")
		case .classD:
			return NSLocalizedString("TILE_LAYER_CLASS_D", bundle: bundle, value: "Class D Controlled Airspace", comment: "Name for map layer Class D Airspace")
		case .classE:
			return NSLocalizedString("TILE_LAYER_CLASS_E", bundle: bundle, value: "Class E Controlled Airspace", comment: "Name for map layer Class E Airspace")
		case .custom:
			return NSLocalizedString("TILE_LAYER_CUSTOM", bundle: bundle, value: "Custom", comment: "Name for map layer Custom")
		case .essentialAirspace:
			return NSLocalizedString("TILE_LAYER_CONTROLLED_AIRSPACE", bundle: bundle, value: "Controlled Airspace (B, C, D & E)", comment: "Name for map layer Controlled Airspace")
		case .hazardAreas:
			return NSLocalizedString("TILE_LAYER_HAZARD_AREAS", bundle: bundle, value: "Hazard Areas", comment: "Name for map layer Hazard Areas")
		case .heliports:
			return NSLocalizedString("TILE_LAYER_HELIPORTS", bundle: bundle, value: "Heliports", comment: "Name for map layer Heliports")
		case .hospitals:
			return NSLocalizedString("TILE_LAYER_HOSPITALS", bundle: bundle, value: "Hospitals", comment: "Name for map layer Hospitals")
		case .nationalParks:
			return NSLocalizedString("TILE_LAYER_NATIONAL_PARKS", bundle: bundle, value: "National Parks", comment: "Name for map layer National Parks")
		case .noaa:
			return NSLocalizedString("TILE_LAYER_NOAA", bundle: bundle, value: "NOAA Marine Protection Areas", comment: "Name for map layer NOAA Marine Protection Areas")
		case .powerPlants:
			return NSLocalizedString("TILE_LAYER_POWER_PLANTS", bundle: bundle, value: "Power Plants", comment: "Name for map layer Power Plants")
		case .prisons:
			return NSLocalizedString("TILE_LAYER_PRISONS", bundle: bundle, value: "Prisons", comment: "Name for map layer Prisons")
		case .prohibited:
			return NSLocalizedString("TILE_LAYER_PROHIBITED", bundle: bundle, value: "Prohibited Airspace", comment: "Name for map layer Prohibited Airspace")
		case .recreationalAreas:
			return NSLocalizedString("TILE_LAYER_AERIAL_REC_AREAS", bundle: bundle, value: "Aerial Recreational Areas", comment: "Name for map layer Aerial Recreational Areas")
		case .restricted:
			return NSLocalizedString("TILE_LAYER_RESTRICTED_AIRSPACE", bundle: bundle, value: "Restricted Airspace", comment: "Name for map layer Restricted Airspace")
		case .schools:
			return NSLocalizedString("TILE_LAYER_SCHOOLS", bundle: bundle, value: "Schools", comment: "Name for map layer Schools")
		case .tfrs:
			return NSLocalizedString("TILE_LAYER_TFR_FAA", bundle: bundle, value: "Temporary Flight Restrictions", comment: "Name for map layer FAA Temporary Flight Restrictions")
		case .universities:
			return NSLocalizedString("TILE_LAYER_UNIVERSITIES", bundle: bundle, value: "Universities", comment: "Name for map layer Universities")
		case .wildfires:
			return NSLocalizedString("TILE_LAYER_WILDFIRES", bundle: bundle, value: "Wildfires", comment: "Name for map layer Wildfires")
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
			return .wildfire
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
	]
	
	/// A descriptive title for the airspace type
	public var title: String {
		
		let bundle = AirMapBundle.main

		switch self {
		case .airport:
			return NSLocalizedString("AIRSPACE_TYPE_AIRPORT", bundle: bundle, value: "Airport", comment: "Name for airspace type Airport")
		case .cities:
			return NSLocalizedString("AIRSPACE_TYPE_CITY", bundle: bundle, value: "City", comment: "Name for airspace type City")
		case .controlledAirspace:
			return NSLocalizedString("AIRSPACE_TYPE_CONTROLLED", bundle: bundle, value: "Controlled Airspace", comment: "Name for airspace type Controlled Airspace")
		case .custom:
			return NSLocalizedString("AIRSPACE_TYPE_CUSTOM", bundle: bundle, value: "Custom", comment: "Name for airspace type Custom")
		case .hazardArea:
			return NSLocalizedString("AIRSPACE_TYPE_HAZARD_AREA", bundle: bundle, value: "Hazard Area", comment: "Name for airspace type Hazard Area")
		case .heliport:
			return NSLocalizedString("AIRSPACE_TYPE_HELIPORT", bundle: bundle, value: "Heliport", comment: "Name for airspace type Heliport")
		case .hospital:
			return NSLocalizedString("AIRSPACE_TYPE_HOSPITAL", bundle: bundle, value: "Hospital", comment: "Name for airspace type Hospital")
		case .park:
			return NSLocalizedString("AIRSPACE_TYPE_NATIONAL_PARK", bundle: bundle, value: "National Park", comment: "Name for airspace type National Park")
		case .powerPlant:
			return NSLocalizedString("AIRSPACE_TYPE_POWER_PLANT", bundle: bundle, value: "Power Plant", comment: "Name for airspace type Power Plant")
		case .prison:
			return NSLocalizedString("AIRSPACE_TYPE_PRISON", bundle: bundle, value: "Prison", comment: "Name for airspace type Prison")
		case .recreationalArea:
			return NSLocalizedString("AIRSPACE_TYPE_AERIAL_REC_AREA", bundle: bundle, value: "Aerial Recreational Area", comment: "Name for airspace type Aerial Recreational Area")
		case .school:
			return NSLocalizedString("AIRSPACE_TYPE_SCHOOL", bundle: bundle, value: "School", comment: "Name for airspace type School")
		case .specialUse:
			return NSLocalizedString("AIRSPACE_TYPE_SPECIAL_USE", bundle: bundle, value: "Special Use Airspace", comment: "Name for airspace type Special Use Airspace")
		case .stadium:
			return NSLocalizedString("AIRSPACE_TYPE_STADIUM", bundle: bundle, value: "Stadium", comment: "Name for airspace type Stadium")
		case .tfr:
			return NSLocalizedString("AIRSPACE_TYPE_TFR_FAA", bundle: bundle, value: "Temporary Flight Restriction", comment: "Name for airspace type FAA Temporary Flight Restriction")
		case .university:
			return NSLocalizedString("AIRSPACE_TYPE_UNIVERSITY", bundle: bundle, value: "University", comment: "Name for airspace type University")
		case .wildfire:
			return NSLocalizedString("AIRSPACE_TYPE_WILDFIRE", bundle: bundle, value: "Wildfire", comment: "Name for airspace type Wildfire")
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
