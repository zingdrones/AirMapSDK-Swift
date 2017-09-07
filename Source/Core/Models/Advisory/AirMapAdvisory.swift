//
//  AirMapAdvisory.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 4/8/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

/// An airspace object that interects with an intended area of operation.
public struct AirMapAdvisory {
	
	/// The advisory's unique identifier
	public let id: String
	
	/// The airspace classification type
	public let type: AirMapAirspaceType
	
	/// A color representative of the advisory level
	public let color: Color
	
	/// A descriptive title
	public let name: String
	
	/// The location of the advisory
	public let coordinate: Coordinate2D
	
	/// The distance from the area that generated the advisory
	public let distance: Meters
	
	/// The advisory location's city
	public let city: String?

	/// The advisory location's state/province
	public let state: String?

	/// The advisory location's country
	public let country: String
	
	/// The identifier of the rule that generated the advisory
	public let ruleId: Int

	/// The identifier of the ruleset from which the rule originated
	public let rulesetId: String
	
	/// Additional metadata specific to the advisory type
	public let properties: PropertiesType?

	/// Any requirements necessary to operate within the advisory
	public let requirements: AirMapAdvisoryRequirements?

	/// The date and time the advisory was last updated
	public let lastUpdated: Date
	
	/// A color representative of the action level of the advisory
	public enum Color: String {
		case red
		case orange
		case yellow
		case green
	}
	
	public struct Properties {
		
		/// Airport advisory properties
		public struct Airport: PropertiesType {
			public let identifier: String?
			public let phone: String?
			public let tower: Bool?
			public let paved: Bool?
			public let longestRunway: Int?
			public let elevation: Int?
			public let publicUse: Bool?
		}
		
		/// Controlled Airspace advisory properties
		public struct ControlledAirspace: PropertiesType {
			public let airspaceClass: String?
			public let airportIdentifier: String?
		}

		/// Emergency advisory properties
		public struct Emergency: PropertiesType {
			public let effective: Date?
			public let type: String?
		}
	
		/// Fire advisory properties
		public struct Fire: PropertiesType {
			public let effective: Date?
		}
		
		/// Park advisory properties
		public struct Park: PropertiesType {
			public let size: Int?
		}

		/// Power Plant advisory properties
		public struct PowerPlant: PropertiesType {
			public let technology: String?
			public let generatorType: String?
			public let output: Int?
		}

		/// School advisory properties
		public struct School: PropertiesType {
			public let numberOfStudents: Int?
		}
		
		/// Special Use advisory properties
		public struct SpecialUse: PropertiesType {
			public let description: String?
		}
		
		/// TFR advisory properties
		public struct TFR: PropertiesType {
			public let url: URL
			public let startTime: Date?
			public let endTime: Date?
		}

		/// Wildfire advisory properties
		public struct Wildfire: PropertiesType {
			public let effective: Date?
			public let size: Hectares?
		}
	}
}

public protocol PropertiesType {}

// MARK: - CustomStringConvertible

extension AirMapAdvisory.Color: CustomStringConvertible {
	
	public var description: String {
		
		let localized = LocalizedStrings.Status.self
		
		switch self {
		case .red:
			return localized.redDescription
		case .orange:
			return localized.orangeDescription
		case .yellow:
			return localized.yellowDescription
		case .green:
			return localized.greenDescription
		}
	}
}
