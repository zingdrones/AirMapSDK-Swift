//
//  AirMap+JSONSerialization.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/1/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation

// MARK: - AdvisoryPropertiesType

public protocol AdvisoryPropertiesType {}

extension AirMapPilotStats {

	private struct Flights: Codable {
		let total: Int
		let lastFlightTime: Date?
	}
	private struct Aircraft: Codable {
		let total: Int
	}

	private enum CodingKeys: String, CodingKey {
		case flight
		case aircraft
	}

	public init(from decoder: Decoder) throws {

		let container = try decoder.container(keyedBy: CodingKeys.self)

		let flights = try container.decode(Flights.self, forKey: .flight)
		totalFlights = flights.total
		lastFlightTime = flights.lastFlightTime

		let aircraft = try container.decode(Aircraft.self, forKey: .aircraft)
		totalAircraft = aircraft.total
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		let flight = Flights(total: totalFlights, lastFlightTime: lastFlightTime)
		try container.encode(flight, forKey: .flight)

		let aircraft = Aircraft(total: totalAircraft)
		try container.encode(aircraft, forKey: .aircraft)
	}
}

extension AirMapPilot {

	enum CodingKeys: String, CodingKey {
		case id
		case email
		case firstName
		case lastName
		case username
		case pictureUrl
		case phone
		case statistics
		case anonymizedId
		case verificationStatus
	}

	struct VerificationStatus: Codable {
		let phone: Bool
		let email: Bool
	}

	public func encode(to encoder: Encoder) throws {

		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(email, forKey: .email)
		try container.encode(firstName, forKey: .firstName)
		try container.encode(lastName, forKey: .lastName)
		try container.encode(username, forKey: .username)
		try container.encode(pictureUrl, forKey: .pictureUrl)
		try container.encode(phone, forKey: .phone)
		try container.encode(statistics, forKey: .statistics)
		try container.encode(anonymizedId, forKey: .anonymizedId)

		let verificationStatus = VerificationStatus(phone: phoneVerified, email: emailVerified)
		try container.encode(verificationStatus, forKey: .verificationStatus)
	}
}

extension AirMapAdvisory.AirportProperties {
	
//	public init(map: Map) throws {
//		identifier    =  try? map.value("faa")
//		instrumentProcedure
//		              =  try? map.value("instrument_approach_procedure")
//	}
}

extension AirMapAdvisory.AMAFieldProperties {
	
//	public init(map: Map) throws {
//
//		// TODO: Remove once AMA Field data contains proper http URLs
//		if let urlString: String = try? map.value("url"), var urlComponents = URLComponents(string: urlString) {
//			if urlComponents.scheme == nil {
//				urlComponents.scheme = "http"
//			}
//			url = try? urlComponents.asURL()
//		} else {
//			url = nil
//		}
//	}
}

extension AirMapAdvisory.ControlledAirspaceProperties {
	
//		type                   =  try  map.value("type")
//		isLaancProvider        =  try? map.value("laanc")
//		supportsAuthorization  =  try? map.value("authorization")
}


extension AirMapAdvisory.HeliportProperties {
	
//	public init(map: Map) throws {
//		identifier    =  try? map.value("faa")
//		instrumentProcedure
//			=  try? map.value("instrument_approach_procedure")
//	}
}

// MARK: - Aircraft

extension AirMapAircraft {
	
//	public func mapping(map: Map) {
//		model.id   >>>  (map["model_id"], AirMapIdTransform())
//	}
}

// MARK: - AirMapAirspace

extension AirMapAirspace {

//	init(map: Map) throws {
//		propertyBoundary
//			=  try? map.value("related_geometry.property_boundary.geometry", using: GeoJSONToAirMapGeometryTransform())
//	}
}

// MARK: - AirMapRuleset

public protocol CodingContext {}

public enum RulesetOrigin: CodingContext {
	case tileService
	case api
}

extension AirMapFlightPlan.FlightFeatureValue {

	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		if let string = try? container.decode(String.self) {
			self = .string(string)
		} else if let float = try? container.decode(Float.self) {
			self = .float(float)
		} else if let bool = try? container.decode(Bool.self) {
			self = .bool(bool)
		}
		throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unexpected data type")
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		switch self {
		case .bool(let bool):
			try container.encode(bool)
		case .float(let float):
			try container.encode(float)
		case .string(let string):
			try container.encode(string)
		}
	}
}


extension AirMapRuleset {
	
	/// The mapping context from where the JSON originated
	///
	/// - tileService: data from tile service metadata
	/// - airMapApi: data from the ruleset API

	public func oldinit(origin: RulesetOrigin?) throws {
		
		do {
			id        =  try  map.value("id")
			name      = (try? map.value("name")) ?? "?" //TODO: FIXME
			shortName = (try? map.value("short_name")) ?? "?"
			type      =  try  map.value("selection_type")
			isDefault =  try  map.value("default")
			
			switch origin ??	 .airMapApi {
				
			case .airMapApi:
				rules           = try map.value("rules")
				description     = try map.value("description")
				airspaceTypes   = try map.value("airspace_types", using: AirMapAirspaceTypeTransform())
				
			case .tileService:
				rules           =  []
				description     = (try? map.value("short_description")) ?? ""
				airspaceTypes   =  try  map.value("layers", using: AirMapAirspaceTypeTransform())
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

// MARK: - AirMapAirspaceType

/// Custom transform that converts between [String] and [AirMapAirspaceType]
fileprivate class AirMapAirspaceTypeTransform: TransformType {

	public typealias Object = [AirMapAirspaceType]
	public typealias JSON = [String]
	
	init() {}
	
	func transformFromJSON(_ value: Any?) -> [AirMapAirspaceType]? {
		if let rawArray = value as? [String] {
			var airspaceTypes = [AirMapAirspaceType]()
			for rawValue in rawArray {
				if let airspaceType = AirMapAirspaceType(rawValue: rawValue) {
					airspaceTypes.append(airspaceType)
				} else {
					AirMap.logger.debug("Unknown airspace type", rawValue)
				}
			}
			return airspaceTypes
		}
		return nil
	}
	
	func transformToJSON(_ value: [AirMapAirspaceType]?) -> [String]? {
		if let obj = value {
			return obj.map { $0.rawValue }
		}
		return nil
	}
}

// MARK: - AirMapFlight

extension AirMapFlight {

//		var lat: Double?
//		var lng: Double?
//
//		lat <- map["latitude"]
//		lng <- map["longitude"]
//
//		if let lat = lat, let lng = lng {
//			coordinate.latitude = lat
//			coordinate.longitude = lng
//		}

// FIXME: Map pilot
//		pilot       <-  map["pilot"]
//		isPublic    	<-  map["public"]
//		geometry    	<- (map["geometry"], GeoJSONToAirMapGeometryTransform())

//		var endTime: Date?
//		endTime     <- (map["end_time"], dateTransform)
//
//		if let startTime = startTime, let endTime = endTime {
//			duration = endTime.timeIntervalSince(startTime)
//		}
	}
	
	// TODO: Remove and replace with .toJSON()

func persistedField() -> Void {
	
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

extension AirMapJurisdiction {
	
//	public init(map: Map) throws {
//
//		do {
//			id     = try map.value("id")
//			name   = try map.value("name")
//			region = try map.value("region")
//
//			guard let rulesetJSON = map.JSON["rulesets"] as? [[String: Any]] else {
//				throw AirMapError.serialization(.invalidJson)
//			}
//
//			// Patch the JSON with information about the jurisdiction :/
//			var updatedJSON = [[String: Any]]()
//			for var json in rulesetJSON {
//				json["jurisdiction"] = ["id": id.rawValue, "name": name, "region": region.rawValue]
//				updatedJSON.append(json)
//			}
//
//			let mapper = Mapper<AirMapRuleset>(context: AirMapRuleset.Origin.tileService)
//			rulesets = try mapper.mapArray(JSONArray: updatedJSON)
//		}
//		catch {
//			AirMap.logger.error(error)
//			throw error
//		}
//	}
//
//	static let tileServiceMapper = Mapper<AirMapJurisdiction>(context: AirMapRuleset.Origin.tileService)
}


extension AirMapFlightFeature {
	
//	id =  try  map.value("flight_feature")
}

extension AirMapRule {
//		status         = (try? map.value("status")) ?? .unevaluated
//		displayOrder   = (try? map.value("display_order")) ?? Int.max
}


extension AirMapWeather {
//	observations    = try map.value("weather")
}

extension AirMapWeather.Observation {
//		pressure      =  try  map.value("mslp")
//		windBearing   =  try? map.value("wind.heading")
//		windSpeed     =  try  map.value("wind.speed")
//		windGusting   =  try? map.value("wind.gusting")
}

