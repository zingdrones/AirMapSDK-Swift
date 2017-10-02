//
//  AirMap+JSONSerialization.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/1/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

// INTERNAL: Extends objects for Mappable/ImmutableMappable Protocol Conformance

// MARK: - AirMapAirspaceStatus

extension AirMapAirspaceStatus: ImmutableMappable {
	
	public init(map: Map) throws {
		
		do {
			color      =  try map.value("color")
			advisories =  try map.value("advisories")
		}
			
		catch {
			print(error)
			throw error
		}
	}
}

// MARK: - AirMapAdvisory

extension AirMapAdvisory: ImmutableMappable {
	
	public init(map: Map) throws {
		
		let dateTransform = CustomDateFormatTransform(formatString: Constants.AirMapApi.dateFormat)
		
		do {
			id            =  try  map.value("id")
			color         =  try  map.value("color")
			lastUpdated   = (try? map.value("last_updated", using: dateTransform)) ?? Date()
			distance      =  try  map.value("distance")
			type          =  try  map.value("type")
			city          =  try? map.value("city")
			state         =  try? map.value("state")
			country       =  try  map.value("country")
			ruleId        =  try  map.value("rule_id")
			rulesetId     =  try  map.value("ruleset_id")
			requirements  =  try? map.value("requirements")
			
			let latitude  = try map.value("latitude") as Double
			let longitude = try map.value("longitude") as Double
			coordinate = Coordinate2D(latitude: latitude, longitude: longitude)
			
			let airspaceType = try map.value("type") as AirMapAirspaceType
			name = (try? map.value("name") as String) ?? airspaceType.title
			
			let props: [String: Any] = try map.value("properties")

			switch airspaceType {
			case .airport:
				properties = Properties.Airport(JSON: props)
			case .heliport:
				properties = Properties.Heliport(JSON: props)
			case .park:
				properties = Properties.Park(JSON: props)
			case .tfr:
				properties = Properties.TFR(JSON: props)
			case .specialUse:
				properties = Properties.SpecialUse(JSON: props)
			case .powerPlant:
				properties = Properties.PowerPlant(JSON: props)
			case .school:
				properties = Properties.School(JSON: props)
			case .controlledAirspace:
				properties = Properties.ControlledAirspace(JSON: props)
			case .wildfire:
				properties = Properties.Wildfire(JSON: props)
			default:
				properties = nil
			}
		}
			
		catch {
			AirMap.logger.error(error)
			throw error
		}
	}
}

// MARK: - AirMapAdvisoryRequirements

extension AirMapAdvisoryRequirements: ImmutableMappable {
	
	public init(map: Map) throws {
		notice  =  try? map.value("notice")
	}
}

extension AirMapAdvisoryRequirements.Notice: ImmutableMappable {
	
	public init(map: Map) throws {
		digital      = (try? map.value("digital")) ?? false
		phoneNumber  =  try? map.value("phone")
	}
}


// MARK: - AdvisoryPropertiesType

public protocol AdvisoryPropertiesType: ImmutableMappable {}

extension AirMapAdvisory.Properties.Airport: ImmutableMappable {
	
	public init(map: Map) throws {
		identifier    =  try? map.value("airport_id")
		name          =  try? map.value("airport_name")
		phone         =  try? map.value("phone")
		airspaceClass =  try? map.value("airspace_classification")
		use           =  try? map.value("type")
	}
}

extension AirMapAdvisory.Properties.Heliport: ImmutableMappable {
	
	public init(map: Map) throws {
		identifier    =  try? map.value("faa")
		paved         =  try? map.value("paved")
		phone         =  try? map.value("phone")
		tower         =  try? map.value("tower")
		use           =  try? map.value("use")
		instrumentProcedure
		              =  try? map.value("instrument_approach_procedure")
	}
}

extension AirMapAdvisory.Properties.ControlledAirspace: ImmutableMappable {
	
	public init(map: Map) throws {
		type      =  try map.value("type")
	}
}

extension AirMapAdvisory.Properties.Emergency: ImmutableMappable {
	
	public init(map: Map) throws {
		effective   =  try? map.value("date_effective", using: Constants.AirMapApi.dateTransform)
		type        =  try? map.value("type")
	}
}

extension AirMapAdvisory.Properties.Fire: ImmutableMappable {
	
	public init(map: Map) throws {
		effective  =  try? map.value("date_effective", using: Constants.AirMapApi.dateTransform)
	}
}

extension AirMapAdvisory.Properties.Park: ImmutableMappable {
	
	public init(map: Map) throws {
		type  =  try? map.value("type")
	}
}

extension AirMapAdvisory.Properties.PowerPlant: ImmutableMappable {
	
	public init(map: Map) throws {
		technology      =  try? map.value("tech")
		generatorType   =  try? map.value("generator_type")
		output          =  try? map.value("output")
	}
}

extension AirMapAdvisory.Properties.School: ImmutableMappable {
	
	public init(map: Map) throws {
		numberOfStudents  =  try? map.value("students")
	}
}

extension AirMapAdvisory.Properties.SpecialUse: ImmutableMappable {
	
	public init(map: Map) throws {
		description =  try? map.value("description")
	}
}

extension AirMapAdvisory.Properties.TFR: ImmutableMappable {
	
	public init(map: Map) throws {
		url        =  try  map.value("url", using: URLTransform())
		startTime  =  try? map.value("effective_start", using: Constants.AirMapApi.dateTransform)
		endTime    =  try? map.value("effective_end", using: Constants.AirMapApi.dateTransform)
		type       =  try? map.value("type")
		sport      =  try? map.value("sport")
		venue      =  try? map.value("venue")
	}
}

extension AirMapAdvisory.Properties.Wildfire: ImmutableMappable {
	
	public init(map: Map) throws {
		effective   =  try? map.value("date_effective", using: Constants.AirMapApi.dateTransform)
		size        =  try? map.value("size")
	}
}

// MARK: - Aircraft


extension AirMapAircraft {
	
	public func mapping(map: Map) {
		model.id  >>>  map["model_id"]
		nickname  >>>  map["nickname"]
	}
}

// MARK: - AirMapAircraftManufacturer

extension AirMapAircraftManufacturer: ImmutableMappable {
	
	public init(map: Map) throws {
		id   = try map.value("id")
		name = try map.value("name")
	}
	
	public func mapping(map: Map) {
		id  >>>  map["id"]
	}
}

// MARK: - AirMapAircraftModel

extension AirMapAircraftModel: ImmutableMappable {
	
	public init(map: Map) throws {
		id           = try  map.value("id")
		name         = try  map.value("name")
		manufacturer = try  map.value("manufacturer")
		metadata     = try? map.value("metadata")
	}
	
	public func mapping(map: Map) {
		id  >>>  map["id"]
	}
}

// MARK: - AirMapAirspace

extension AirMapAirspace: ImmutableMappable {
	
	init(map: Map) throws {
		id        =  try  map.value("id")
		name      =  try  map.value("name")
		type      =  try  map.value("type")
		country   =  try  map.value("country")
		state     =  try? map.value("state")
		city      =  try? map.value("city")
		geometry  =  try  map.value("geometry", using: GeoJSONToAirMapGeometryTransform())
		propertyBoundary
			=  try? map.value("related_geometry.property_boundary.geometry", using: GeoJSONToAirMapGeometryTransform())
	}
}

// MARK: - AirMapRuleset

extension AirMapRuleset: ImmutableMappable {
	
	/// The mapping context from where the JSON originated
	///
	/// - tileService: data from tile service metadata
	/// - airMapApi: data from the ruleset API
	public enum Origin: MapContext {
		case tileService
		case airMapApi
	}
	
	public init(map: Map) throws {
		
		do {
			id        =  try  map.value("id")
			name      =  try  map.value("name")
			shortName = (try? map.value("short_name")) ?? "?"
			type      =  try  map.value("selection_type")
			isDefault =  try  map.value("default")
			
			switch (map.context as? Origin) ?? .airMapApi {
				
			case .airMapApi:
				rules           = try map.value("rules")
				description     = try map.value("description")
				airspaceTypeIds = try map.value("airspace_types")
				
			case .tileService:
				rules           =  []
				description     = (try? map.value("short_description")) ?? ""
				airspaceTypeIds =  try  map.value("layers")
			}
			
			jurisdictionId     = try? map.value("jurisdiction.id")
			jurisdictionName   = try? map.value("jurisdiction.name")
			jurisdictionRegion = try? map.value("jurisdiction.region")
		}
		catch {
			AirMap.logger.error(error)
			throw error
		}
	}
}

// MARK: - AirMapFlight

extension AirMapFlight: Mappable {
	
	public func mapping(map: Map) {
		
		var lat: Double?
		var lng: Double?
		
		lat <- map["latitude"]
		lng <- map["longitude"]
		
		if let lat = lat, let lng = lng {
			coordinate.latitude = lat
			coordinate.longitude = lng
		}
		
		let dateTransform = CustomDateFormatTransform(formatString: Constants.AirMapApi.dateFormat)
		
		id          <-  map["id"]
		createdAt   <- (map["creation_date"], dateTransform)
		startTime   <- (map["start_time"], dateTransform)
		maxAltitude <-  map["max_altitude"]
		city        <-  map["city"]
		state       <-  map["state"]
		country     <-  map["country"]
		notify      <-  map["notify"]
// FIXME: Map pilot
//		pilot       <-  map["pilot"]
		pilotId     <-  map["pilot_id"]
		aircraft    <-  map["aircraft"]
		aircraftId  <-  map["aircraft_id"]
		isPublic    <-  map["public"]
		buffer      <-  map["buffer"]
		geometry    <- (map["geometry"], GeoJSONToAirMapGeometryTransform())
		
		var endTime: Date?
		endTime     <- (map["end_time"], dateTransform)
		
		if let startTime = startTime, let endTime = endTime {
			duration = endTime.timeIntervalSince(startTime)
		}
	}
	
	// TODO: Remove and replace with .toJSON()
	
	func params() -> [String: Any] {
		
		var params = [String: Any]()
		
		params["latitude"    ] = coordinate.latitude
		params["longitude"   ] = coordinate.longitude
		params["max_altitude"] = maxAltitude
		params["aircraft_id" ] = aircraftId
		params["public"      ] = isPublic
		params["notify"      ] = notify
		params["geometry"    ] = geometry?.params()
		params["buffer"      ] = buffer ?? 0
		
		if let startTime = startTime, let endTime = endTime {
			params["start_time"] = startTime.iso8601String()
			params["end_time"  ] = endTime.iso8601String()
		} else {
			let now = Date()
			params["start_time"] = now.iso8601String()
			params["end_time"  ] = now.addingTimeInterval(duration).iso8601String()
		}
		
		return params
	}
}

// MARK: - AirMapFlightBriefing

extension AirMapFlightBriefing: ImmutableMappable {
	
	public init(map: Map) throws {
		
		let dateTransform = CustomDateFormatTransform(formatString: Constants.AirMapApi.dateFormat)
		do {
			createdAt      =  try  map.value("created_at", using: dateTransform)
			rulesets       =  try  map.value("rulesets")
			status         =  try  map.value("airspace")
			authorizations = (try? map.value("authorizations")) ?? []
			validations    = (try? map.value("validations")) ?? []
		}
		catch {
			AirMap.logger.error(error)
			throw error
		}
	}
}

extension AirMapFlightBriefing.Ruleset: ImmutableMappable {
	
	public init(map: Map) throws {
		id    = try map.value("id")
		rules = try map.value("rules")
	}
}

extension AirMapFlightBriefing.Validation: ImmutableMappable {
	
	public init(map: Map) throws {
		do {
			status     	= try map.value("status")
			feature    	= try map.value("feature")
			authority  	= try map.value("authority")
			message    	= try map.value("message")
			description	= try map.value("description")
		}
		catch {
			AirMap.logger.error(error)
			throw error
		}
	}
}

extension AirMapFlightBriefing.Validation.Feature: ImmutableMappable {
	
	public init(map: Map) throws {
		do {
			code = try map.value("code")
			name = try map.value("description")
		}
		catch {
			AirMap.logger.error(error)
			throw error
		}
	}
}

extension AirMapAuthority: ImmutableMappable {
	
	public init(map: Map) throws {
		do {
			name = try map.value("name")
		}
		catch {
			AirMap.logger.error(error)
			throw error
		}
	}
}

extension AirMapFlightBriefing.Authorization: ImmutableMappable {
	
	public init(map: Map) throws {
		do {
			authority  	= try map.value("authority")
			status     	= try map.value("status")
			message    	= try map.value("message")
			description	= try map.value("description")
		}
		catch {
			AirMap.logger.error(error)
			throw error
		}
	}
}

extension AirMapJurisdiction: ImmutableMappable {
	
	public init(map: Map) throws {
		
		do {
			id     = try map.value("id")
			name   = try map.value("name")
			region = try map.value("region")
			
			guard let rulesetJSON = map.JSON["rulesets"] as? [[String: Any]] else {
				throw AirMapError.serialization(.invalidJson)
			}
			
			// Patch the JSON with information about the jurisdiction :/
			var updatedJSON = [[String: Any]]()
			for var json in rulesetJSON {
				json["jurisdiction"] = ["id": id, "name": name, "region": region.rawValue]
				updatedJSON.append(json)
			}
			
			let mapper = Mapper<AirMapRuleset>(context: AirMapRuleset.Origin.tileService)
			rulesets = try mapper.mapArray(JSONArray: updatedJSON)
		}
		catch {
			AirMap.logger.error(error)
			throw error
		}
	}
}

// MARK: - AirMapFlightFeature

extension AirMapFlightFeature: ImmutableMappable {
	
	public init(map: Map) throws {
		id              =  try  map.value("flight_feature")
		description     =  try  map.value("description")
		inputType       =  try  map.value("input_type")
		measurementType = (try? map.value("measurement_type")) ?? .binary
		measurementUnit =  try? map.value("measurement_unit")
	}
}

// MARK: - AirMapRule

import ObjectMapper

extension AirMapRule: ImmutableMappable {
	
	public init(map: Map) throws {
		shortText      =  try? map.value("short_text")
		description    =  try  map.value("description")
		flightFeatures = (try? map.value("flight_features")) ?? []
		status         = (try? map.value("status")) ?? .unevaluated
		displayOrder   = (try? map.value("display_order")) ?? Int.max
	}
}

// MARK: - AirMapToken

extension AirMapToken: ImmutableMappable {
	
	public init(map: Map) throws {
		authToken = try map.value("id_token")
	}
}

// MARK: - Auth0Credentials

extension Auth0Credentials: ImmutableMappable {
	
	public init(map: Map) throws {
		accessToken   =  try map.value("access_token")
		refreshToken  =  try map.value("refresh_token")
		tokenType     =  try map.value("token_type")
		idToken       =  try map.value("id_token")
	}
}

// MARK: - AirMapWeather

extension AirMapWeather: ImmutableMappable {
	
	public init(map: Map) throws {
		do {
			attribution     = try map.value("attribution")
			attributionUrl  = try map.value("attribution_uri", using: URLTransform())
			observations    = try map.value("weather")
		}
		catch {
			print(error)
			throw error
		}
	}
}

extension AirMapWeather.Observation: ImmutableMappable {
	
	private static let dateTransform = CustomDateFormatTransform(formatString: Constants.AirMapApi.dateFormat)
	
	public init(map: Map) throws {
		do {
			time          =  try  map.value("time", using: AirMapWeather.Observation.dateTransform)
			condition     =  try  map.value("condition")
			icon          =  try  map.value("icon")
			dewPoint      =  try  map.value("dew_point")
			pressure      =  try  map.value("mslp")
			humidity      =  try  map.value("humidity")
			visibility    =  try? map.value("visibility")
			precipitation =  try  map.value("precipitation")
			temperature   =  try  map.value("temperature")
			windBearing   =  try  map.value("wind.heading")
			windSpeed     =  try  map.value("wind.speed")
			windGusting   =  try? map.value("wind.gusting")
		}
		catch {
			print(error)
			throw error
		}
	}
}
