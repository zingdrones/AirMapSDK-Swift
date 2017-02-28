//
//  LocalizedStrings.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 2/27/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

internal struct LocalizedString {
	
	private static let bundle = AirMapBundle.core
	
	
	struct Status {
		
		static let redDescription = NSLocalizedString(
			"STATUS_RED_DESCRIPTION", bundle: bundle,
			value: "Flight Strictly Regulated",
			comment: "Description for status advisory color Red")
		
		static let yellowDescription = NSLocalizedString(
			"STATUS_YELLOW_DESCRIPTION", bundle: bundle,
			value: "Advisories",
			comment: "Description for status advisory color Yellow")
		
		static let greenDescription = NSLocalizedString(
			"STATUS_GREEN_DESCRIPTION", bundle: bundle,
			value: "Informational",
			comment: "Description for status advisory color Green")

	}
	
	struct MapLayer {
		
		static let airports = NSLocalizedString(
			"TILE_LAYER_AIRPORTS", bundle: bundle,
			value: "Airports",
			comment: "Name for map layer Commercial Airports")
		
		static let airportsPrivate = NSLocalizedString(
			"TILE_LAYER_PRIVATE_AIRPORTS", bundle: bundle,
			value: "Private Airports",
			comment: "Name for map layer Private Airports")
		
		static let cities = NSLocalizedString(
			"TILE_LAYER_CITIES", bundle: bundle,
			value: "Cities",
			comment: "Name for map layer Cities")
		
		static let classB = NSLocalizedString(
			"TILE_LAYER_CLASS_B", bundle: bundle,
			value: "Class B Controlled Airspace",
			comment: "Name for map layer Class B Airspace")
		
		static let classC = NSLocalizedString(
			"TILE_LAYER_CLASS_C", bundle: bundle,
			value: "Class C Controlled Airspace",
			comment: "Name for map layer Class C Airspace")
		
		static let classD = NSLocalizedString(
			"TILE_LAYER_CLASS_D", bundle: bundle,
			value: "Class D Controlled Airspace",
			comment: "Name for map layer Class D Airspace")
		
		static let classE = NSLocalizedString(
			"TILE_LAYER_CLASS_E", bundle: bundle,
			value: "Class E Controlled Airspace",
			comment: "Name for map layer Class E Airspace")
		
		static let custom = NSLocalizedString(
			"TILE_LAYER_CUSTOM", bundle: bundle,
			value: "Custom",
			comment: "Name for map layer Custom")
		
		static let essentionalAirspace = NSLocalizedString(
			"TILE_LAYER_CONTROLLED_AIRSPACE", bundle: bundle,
			value: "Controlled Airspace (B, C, D & E)",
			comment: "Name for map layer Controlled Airspace")
		
		static let hazardAreas = NSLocalizedString(
			"TILE_LAYER_HAZARD_AREAS", bundle: bundle,
			value: "Hazard Areas",
			comment: "Name for map layer Hazard Areas")
		
		static let heliports = NSLocalizedString(
			"TILE_LAYER_HELIPORTS", bundle: bundle,
			value: "Heliports",
			comment: "Name for map layer Heliports")
		
		static let hospitals = NSLocalizedString(
			"TILE_LAYER_HOSPITALS", bundle: bundle,
			value: "Hospitals",
			comment: "Name for map layer Hospitals")
		
		static let nationalParks = NSLocalizedString(
			"TILE_LAYER_NATIONAL_PARKS", bundle: bundle,
			value: "National Parks",
			comment: "Name for map layer National Parks")
		
		static let noaa = NSLocalizedString(
			"TILE_LAYER_NOAA", bundle: bundle,
			value: "NOAA Marine Protection Areas",
			comment: "Name for map layer NOAA Marine Protection Areas")
		
		static let powerPlants = NSLocalizedString(
			"TILE_LAYER_POWER_PLANTS", bundle: bundle,
			value: "Power Plants",
			comment: "Name for map layer Power Plants")
		
		static let prisons = NSLocalizedString(
			"TILE_LAYER_PRISONS", bundle: bundle,
			value: "Prisons",
			comment: "Name for map layer Prisons")
		
		static let prohibited = NSLocalizedString(
			"TILE_LAYER_PROHIBITED", bundle: bundle,
			value: "Prohibited Airspace",
			comment: "Name for map layer Prohibited Airspace")
		
		static let recreationalAreas = NSLocalizedString(
			"TILE_LAYER_AERIAL_REC_AREAS", bundle: bundle,
			value: "Aerial Recreational Areas",
			comment: "Name for map layer Aerial Recreational Areas")
		
		static let restricted = NSLocalizedString(
			"TILE_LAYER_RESTRICTED_AIRSPACE", bundle: bundle,
			value: "Restricted Airspace",
			comment: "Name for map layer Restricted Airspace")
		
		static let schools = NSLocalizedString(
			"TILE_LAYER_SCHOOLS", bundle: bundle,
			value: "Schools", comment: "Name for map layer Schools")
		
		static let tfrs = NSLocalizedString(
			"TILE_LAYER_TFR_FAA", bundle: bundle,
			value: "Temporary Flight Restrictions",
			comment: "Name for map layer FAA Temporary Flight Restrictions")
		
		static let universities = NSLocalizedString(
			"TILE_LAYER_UNIVERSITIES", bundle: bundle,
			value: "Universities",
			comment: "Name for map layer Universities")
		
		static let wildfires = NSLocalizedString(
			"TILE_LAYER_WILDFIRES", bundle: bundle,
			value: "Wildfires",
			comment: "Name for map layer Wildfires")
	}
	
	struct AirspaceType {
		
		static let airport = NSLocalizedString(
			"AIRSPACE_TYPE_AIRPORT", bundle: bundle,
			value: "Airport",
			comment: "Name for airspace type Airport")
		
		static let city = NSLocalizedString(
			"AIRSPACE_TYPE_CITY", bundle: bundle,
			value: "City",
			comment: "Name for airspace type City")
		
		static let controlledAirspace = NSLocalizedString(
			"AIRSPACE_TYPE_CONTROLLED", bundle: bundle,
			value: "Controlled Airspace",
			comment: "Name for airspace type Controlled Airspace")
		
		static let custom = NSLocalizedString(
			"AIRSPACE_TYPE_CUSTOM", bundle: bundle,
			value: "Custom",
			comment: "Name for airspace type Custom")
		
		static let hazardArea = NSLocalizedString(
			"AIRSPACE_TYPE_HAZARD_AREA", bundle: bundle,
			value: "Hazard Area",
			comment: "Name for airspace type Hazard Area")

		static let heliport = NSLocalizedString(
			"AIRSPACE_TYPE_HELIPORT", bundle: bundle,
			value: "Heliport",
			comment: "Name for airspace type Heliport")

		static let hospital = NSLocalizedString(
			"AIRSPACE_TYPE_HOSPITAL", bundle: bundle,
			value: "Hospital",
			comment: "Name for airspace type Hospital")

		static let park = NSLocalizedString(
			"AIRSPACE_TYPE_NATIONAL_PARK", bundle: bundle,
			value: "National Park",
			comment: "Name for airspace type National Park")

		static let powerPlant = NSLocalizedString(
			"AIRSPACE_TYPE_POWER_PLANT", bundle: bundle,
			value: "Power Plant",
			comment: "Name for airspace type Power Plant")

		static let prison = NSLocalizedString(
			"AIRSPACE_TYPE_PRISON", bundle: bundle,
			value: "Prison",
			comment: "Name for airspace type Prison")

		static let recreationalArea = NSLocalizedString(
			"AIRSPACE_TYPE_AERIAL_REC_AREA", bundle: bundle,
			value: "Aerial Recreational Area",
			comment: "Name for airspace type Aerial Recreational Area")

		static let school = NSLocalizedString(
			"AIRSPACE_TYPE_SCHOOL", bundle: bundle,
			value: "School",
			comment: "Name for airspace type School")

		static let specialUse = NSLocalizedString(
			"AIRSPACE_TYPE_SPECIAL_USE", bundle: bundle,
			value: "Special Use Airspace",
			comment: "Name for airspace type Special Use Airspace")

		static let stadium = NSLocalizedString(
			"AIRSPACE_TYPE_STADIUM", bundle: bundle,
			value: "Stadium",
			comment: "Name for airspace type Stadium")

		static let tfr = NSLocalizedString(
			"AIRSPACE_TYPE_TFR_FAA", bundle: bundle,
			value: "Temporary Flight Restriction",
			comment: "Name for airspace type FAA Temporary Flight Restriction")

		static let university = NSLocalizedString(
			"AIRSPACE_TYPE_UNIVERSITY", bundle: bundle,
			value: "University",
			comment: "Name for airspace type University")

		static let wildfire = NSLocalizedString(
			"AIRSPACE_TYPE_WILDFIRE", bundle: bundle,
			value: "Wildfire",
			comment: "Name for airspace type Wildfire")
	}
	
	struct CardinalDirection {
		
		static let N   = NSLocalizedString("CARDINAL_DIRECTION_N",    bundle: bundle, value: "N",   comment: "Abbreviation for North")
		static let NNE = NSLocalizedString("CARDINAL_DIRECTION_NNNE", bundle: bundle, value: "NNE", comment: "Abbreviation for North North East")
		static let NE  = NSLocalizedString("CARDINAL_DIRECTION_NE",   bundle: bundle, value: "NE",  comment: "Abbreviation for North East")
		static let ENE = NSLocalizedString("CARDINAL_DIRECTION_ENE",  bundle: bundle, value: "ENE", comment: "Abbreviation for East North East")
		static let E   = NSLocalizedString("CARDINAL_DIRECTION_E",    bundle: bundle, value: "E",   comment: "Abbreviation for East")
		static let ESE = NSLocalizedString("CARDINAL_DIRECTION_ESE",  bundle: bundle, value: "ESE", comment: "Abbreviation for East South East")
		static let SE  = NSLocalizedString("CARDINAL_DIRECTION_SE",   bundle: bundle, value: "SE",  comment: "Abbreviation for South East")
		static let SSE = NSLocalizedString("CARDINAL_DIRECTION_SSE",  bundle: bundle, value: "SSE", comment: "Abbreviation for South South East")
		static let S   = NSLocalizedString("CARDINAL_DIRECTION_S",    bundle: bundle, value: "S",   comment: "Abbreviation for South")
		static let SSW = NSLocalizedString("CARDINAL_DIRECTION_SSW",  bundle: bundle, value: "SSW", comment: "Abbreviation for South South West")
		static let SW  = NSLocalizedString("CARDINAL_DIRECTION_SW",   bundle: bundle, value: "SW",  comment: "Abbreviation for South West")
		static let WSW = NSLocalizedString("CARDINAL_DIRECTION_WSW",  bundle: bundle, value: "WSW", comment: "Abbreviation for West South West")
		static let W   = NSLocalizedString("CARDINAL_DIRECTION_W",    bundle: bundle, value: "W",   comment: "Abbreviation for West")
		static let WNW = NSLocalizedString("CARDINAL_DIRECTION_WNW",  bundle: bundle, value: "WNW", comment: "Abbreviation for West North West")
		static let NW  = NSLocalizedString("CARDINAL_DIRECTION_NW",   bundle: bundle, value: "NW",  comment: "Abbreviation for North West")
		static let NNW = NSLocalizedString("CARDINAL_DIRECTION_NNW",  bundle: bundle, value: "NNW", comment: "Abbreviation for North North West")
	}
	
	struct Units {
		
		static let groundSpeedFormat = NSLocalizedString(
			"GROUND_SPEED_FORMAT", bundle: AirMapBundle.core,
			value: "%1$@ %2$@",
			comment: "Format for displaying ground speed. 1) value 2) unit")
		
		static let groundSpeedMetersPerSecond = NSLocalizedString(
			"GROUND_SPEED_UNIT_METERS_PER_SECOND", bundle: AirMapBundle.core,
			value: "m/s",
			comment: "Unit for displaying ground speed")
		
		static let groundSpeedKnots = NSLocalizedString(
			"GROUND_SPEED_UNIT_KNOTS", bundle: AirMapBundle.core,
			value: "kts",
			comment: "Unit for displaying ground speed")
	}
	
	struct Error {
		
		static let unauthorized = NSLocalizedString(
			"ERROR_UNAUTHORIZED", bundle: bundle,
			value: "Unauthorized. Please check login credentials.",
			comment: "Authorization failure error")
		
		static let server = NSLocalizedString(
			"ERROR_SERVER", bundle: bundle,
			value: "The server could not complete your request.",
			comment: "Server failure error")
		
		static let serialization = NSLocalizedString(
			"ERROR_SERIALIZATION", bundle: bundle,
			value: "The server returned an unprocessible response.",
			comment: "Response serialization failure error")
		
		static let genericFormat = NSLocalizedString(
			"ERROR_GENERIC_FORMAT", bundle: bundle,
			value: "The server returned an error. (%@)",
			comment: "A generic server error message with an associated error code")
	}
	
}
