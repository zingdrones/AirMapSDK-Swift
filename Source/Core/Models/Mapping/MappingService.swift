//
//  AirMapMapTiles.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/6/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

/**
Supported Map Layers
*/

public enum AirMapLayerType: Int {

	case TFRS
	case Wildfires
	case Prohibited
	case Restricted
	case NationalParks
	case NOAA
	case Schools
	case Hospitals
	case Heliports
	case PowerPlants
	case AirportsCommercial
	case AirportsCommercialPrivate
	case AirportsRecreational
	case AirportsRecreationalPrivate
	case ClassB
	case ClassC
	case ClassD
	case ClassE
	case EssentailAirspace

	public static let allLayerTypes = [
		TFRS,
		Wildfires,
		Prohibited,
		Restricted,
		NationalParks,
		NOAA,
		Schools,
		Hospitals,
		Heliports,
		PowerPlants,
		AirportsCommercial,
		AirportsRecreational,
		ClassB,
		ClassC,
		ClassD,
		ClassE,
		AirportsCommercialPrivate,
		AirportsRecreationalPrivate
	]

	public var type: String {

		switch self {
		case .TFRS:
			return "tfrs"
		case .Wildfires:
			return "wildfires"
		case .Prohibited:
			return "sua_prohibited"
		case .Restricted:
			return "sua_restricted"
		case .NationalParks:
			return "national_parks"
		case .NOAA:
			return "noaa"
		case .Schools:
			return "schools"
		case .Hospitals:
			return "hospitals"
		case .Heliports:
			return "heliports"
		case .PowerPlants:
			return "power_plants"
		case .AirportsCommercial:
			return "airports_commercial"
		case .AirportsRecreational:
			return	"airports_recreational"
		case .AirportsCommercialPrivate:
			return "airports_commercial_private"
		case .AirportsRecreationalPrivate:
			return	"airports_recreational_private"
		case .ClassB:
			return "class_b"
		case .ClassC:
			return "class_c"
		case .ClassD:
			return "class_d"
		case .ClassE:
			return "class_e0"  // ClassE *at the surface
		case EssentailAirspace:
			return "class_b,class_c,class_d,class_e0"
		}
	}

	public var category: String {

		switch self {
		case .TFRS:
			return "TFRs"
		case .Wildfires:
			return "Wildfires"
		case .Prohibited, .Restricted:
			return "Special Use Airspace"
		case .NationalParks:
			return "National Park"
		case .NOAA:
			return "NOAA"
		case .Schools:
			return "School"
		case .Hospitals:
			return "Hospital"
		case .Heliports:
			return "Heliport"
		case .PowerPlants:
			return "Power Plant"
		case .AirportsCommercial, .AirportsRecreational, AirportsCommercialPrivate, .AirportsRecreationalPrivate:
			return "Airport"
		case .ClassB, .ClassC, .ClassD, .ClassE, .EssentailAirspace:
			return "Controlled Airspace"
		}
	}

	public var title: String {

		switch self {
		case .TFRS:
			return "Temporary Flight Restriction"
		case .Wildfires:
			return "Wildfires"
		case .Prohibited:
			return "Prohibited Area"
		case .Restricted:
			return "Restricted Area"
		case .NationalParks:
			return "National Park"
		case .NOAA:
			return "NOAA"
		case .Schools:
			return "School"
		case .Hospitals:
			return "Hospital"
		case .Heliports:
			return "Heliport"
		case .PowerPlants:
			return "Power Plant"
		case .AirportsCommercial:
			return "Airport"
		case .AirportsRecreational:
			return	"Airport"
		case .AirportsCommercialPrivate:
			return "Private Airport"
		case .AirportsRecreationalPrivate:
			return	"Private Airport"
		case .ClassB:
			return "Class B Airspace"
		case .ClassC:
			return "Class C Airspace"
		case .ClassD:
			return "Class D Airspace"
		case .ClassE:
			return "Class E Airspace"  // ClassE *at the surface
		case EssentailAirspace:
			return "Essential Airspace (B, C, D & E)"
		}
	}

	public var description: String {

		switch self {
		case .TFRS:
			return "Temporary flight restriction"
		case .Wildfires:
			return "Wildfires"
		case .Prohibited:
			return "Prohibited airspace"
		case .Restricted:
			return "Restricted airspace"
		case .NationalParks:
			return "National park"
		case .NOAA:
			return "NOAA marine protection area"
		case .Schools:
			return "School"
		case .Hospitals:
			return "Hospital"
		case .Heliports:
			return "Heliport"
		case .PowerPlants:
			return "Power Plant"
		case .AirportsCommercial:
			return "Airport"
		case .AirportsRecreational:
			return	"Airport"
		case .AirportsCommercialPrivate:
			return "Private Airport"
		case .AirportsRecreationalPrivate:
			return	"Private Airport"
		case .ClassB:
			return "Class B controlled airspace"
		case .ClassC:
			return "Class C controlled airspace"
		case .ClassD:
			return "Class D controlled airspace"
		case .ClassE:
			return "Class E controlled airspace to the surface"
		case EssentailAirspace:
			return "Essential Airspace (B, C, D & E)"
		}
	}

	public var airSpaceType: AirMapAirspaceType {

		switch self {
		case .AirportsCommercial,
		     .AirportsRecreational,
		     .AirportsRecreationalPrivate,
		     .AirportsCommercialPrivate:
			return .Airport

		case .NationalParks,
		     .NOAA:

			return AirMapAirspaceType.Park

		case .Heliports,
		     .ClassB,
		     .ClassC,
		     .ClassD,
		     .ClassE,
		     .EssentailAirspace:
			return .ControlledAirspace

		case .Hospitals:
		     return.Hospitals

		case .PowerPlants:
			return .PowerPlant

		case .Schools:
			return .School

		case .TFRS,
		     .Restricted,
		     .Prohibited:
			return .SpecialUse

		case .Wildfires:
		     return .Wildfires
		}
	}
}

public enum AirMapAirspaceType: Int {

	case Airport
	case Park
	case Hospitals
	case PowerPlant
	case ControlledAirspace
	case School
	case SpecialUse
	case TFR
	case Wildfires

	public var type: String {

		switch self {
		case Airport:
			return "airport"
		case Park:
			return "park"
		case PowerPlant:
			return "power_plant"
		case ControlledAirspace:
			return "controlled_airspace"
		case School:
			return "school"
		case SpecialUse:
			return "special_use_airspace"
		case TFR:
			return "tfr"
		case Wildfires:
			return "wildfire"
		case Hospitals:
			return "wildfire"
		}
	}

	public var title: String {

		switch self {
		case Airport:
			return "Airports"
		case Park:
			return "Parks"
		case PowerPlant:
			return "Power Plants"
		case ControlledAirspace:
			return "Controlled Airspace"
		case School:
			return "Schools"
		case SpecialUse:
			return "Special Use Airspace"
		case TFR:
			return "Temporary Flight Restrictions"
		case Wildfires:
			return "Wildfires"
		case .Hospitals:
			return "Hospitals"
		}
	}

	public static let allAirspaceTypes: [AirMapAirspaceType] = [
		.Airport,
		.Park,
		.Hospitals,
		.PowerPlant,
		.ControlledAirspace,
		.School,
		.SpecialUse,
		.TFR,
		.Wildfires
	]

	public static func airspaceTypeFromName(name: String) -> AirMapAirspaceType? {

		switch name {
		case AirMapAirspaceType.Airport.type:
			return .Airport
		case AirMapAirspaceType.Park.type:
			return .Park
		case AirMapAirspaceType.Hospitals.type:
			return .Hospitals
		case AirMapAirspaceType.PowerPlant.type:
			return .PowerPlant
		case AirMapAirspaceType.ControlledAirspace.type:
			return .ControlledAirspace
		case AirMapAirspaceType.School.type:
			return .School
		case AirMapAirspaceType.Airport.type:
			return .Airport
		case AirMapAirspaceType.SpecialUse.type:
			return .SpecialUse
		case AirMapAirspaceType.TFR.type:
			return .TFR
		case AirMapAirspaceType.Wildfires.type:
			return .Wildfires
		default:
			return nil
		}
	}
}

/**
Supported Map Themes
*/
public enum AirMapMapTheme: Int {

	case Standard
	case Dark
	case Light
	case Satellite

	public var name: String {
		switch self {
		case .Standard:
			return "standard"
		case .Dark:
			return "dark"
		case .Light:
			return "light"
		case .Satellite:
			return "satellite"
		}
	}

}

internal class MappingService {

	/**
	
	Generates and returns map tile source url based upon Map Layers & Theme.

	- parameter layers:[AirMapMapLayer] An array of AirMapMapLayer's.
	- parameter theme:[AirMapMapTheme] An AirMapMapTheme.

	- returns: NSURL?
	
	*/
	func tileSourceUrl(layers: [AirMapLayerType], theme: AirMapMapTheme) -> NSURL? {

		guard let apiKey = AirMap.authSession.apiKey else { return nil }

		let tiles  = layers.count == 0 ? "_-_" : layers.flatMap{$0.type}.joinWithSeparator(",")
		let urlString = Config.AirMapApi.mapTilesUrl + "/\(tiles)?&theme=\(theme.name)&apikey=\(apiKey)&token=\(apiKey)"

		if let url = NSURL(string: urlString) {
			return url
		}

		return nil
	}


}
