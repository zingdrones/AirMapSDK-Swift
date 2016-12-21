//
//  AirMapAnalytics.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 12/16/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

public protocol AirMapAnalyticsDelegate: class {
	
	func analyticsDidTrackScreen(screen: String)
	func analyticsDidTrackEvent(category: String, action: String, label: String?, value: Int?)
	func analyticsDidTrackException(exception: String, fatal: Bool)
	func analyticsDidTrackUserProperty(property: [String: AnyObject])
}

public protocol AnalyticsFlow {}

public protocol AnalyticsScreen: SelfDescribable {
	associatedtype ActionType: AnalyticsAction
	static var name: String { get }
	var action: ActionType { get }
}

public protocol AnalyticsAction: SelfDescribable {}
public protocol AnalyticsUserProperty {
	var keyValue: [String: AnyObject] { get }
}

class TestThisOut {
	
	func sendAnalytics() {
		
		AirMapAnalytics.trackView(PilotProfileScreen)
		AirMapAnalytics.trackEvent(PilotProfileScreen(action: .EditProfile))
	}
}

public class AirMapAnalytics {
	
	static weak public var delegate: AirMapAnalyticsDelegate?
	
	static func trackView<A: AnalyticsScreen>(screen: A.Type) {
		delegate?.analyticsDidTrackScreen(screen.name)
	}
	
	static func trackEvent<A: AnalyticsScreen>(action: A) {
//		delegate?.analyticsDidTrackEvent(action.dynamicType.name, action: action.description, label: label, value: value)
	}
	
	static func trackException(exception: String, fatal: Bool) {
		delegate?.analyticsDidTrackException(exception, fatal: fatal)
	}
	
	static func trackUser(property: AnalyticsUserProperty) {
		delegate?.analyticsDidTrackUserProperty(property.keyValue)
	}
}

struct CreateFlight: AnalyticsFlow {
	
	struct GeoType: AnalyticsScreen {
		static let name = "Create Flight: Geo Type"
		var action: Action
		enum Action: AnalyticsAction {
			case ToggledFlightType(type: AirMapFlight.FlightGeometryType)
			case AdjustedRadius(value: Double)
			case ViewAdvisories
			case DeletedShape
			case DrewCustomShape
			case SaveFlightType
		}
	}
	
	struct Details: AnalyticsScreen {
		static let name = "Create Flight: Set Details"
		var action: Action
		enum Action: AnalyticsAction {
			case ChangedAltitude(value: Double)
			case ChangeStartTime
			case ChangedDuration(value: Double)
			case ViewPilotInfo
			case SelectAircraft
			case ToggledPublicFlight(value: Bool)
			case SaveFlightDetails
			case CreateFlight
			
			case ReadFAQ
		}
	}

	struct DigitalNotice: AnalyticsScreen {
		static let name = "Create Flight: Digital Notice"
		var action: Action
		enum Action: AnalyticsAction {
			case CallAdvisory
			case SaveDigitalNotice
		}
	}
	
	struct Review: AnalyticsScreen {
		static let name = "Create Flight: Review Flight"
		var action: Action
		enum Action: AnalyticsAction {
			case CreateFlight
		}
	}
}

struct PilotProfileScreen: AnalyticsScreen {
	static let name = "Pilot Profile"
	var action: Action
	enum Action: AnalyticsAction {
		case EditProfile
		case VerifyPhoneNumber
	}
}

struct VerifyPhoneNumber: AnalyticsScreen {
	static let name = "Verify Phone Number"
	var action: Action
	enum Action: AnalyticsAction {
		case SelectCountry
		case SavePhoneNumber
	}
}

struct AircraftListScreen: AnalyticsScreen {
	static let name = "List Aircraft"
	var action: Action
	enum Action: AnalyticsAction {
		case AddAircraft
		case EditAircraft
		case DeleteAircraft
	}
}

struct AircraftCreateScreen: AnalyticsScreen {
	static let name = "Create Aircraft"
	var action: Action
	enum Action: AnalyticsAction {
		case SelectMakeAndModel
		case SaveAircraft
	}
}

struct AircraftUpdateScreen: AnalyticsScreen {
	static let name = "Update Aircraft"
	var action: Action
	enum Action: AnalyticsAction {
		case SaveAircraft
	}
}

struct AircraftMakeScreen: AnalyticsScreen {
	static let name = "Select Aircraft Make"
	var action: Action
	enum Action: AnalyticsAction {
		case selectMake(name: String)
	}
}

struct AircraftModelScreen: AnalyticsScreen {
	static let name = "Select Aircraft Model"
	var action: Action
	enum Action: AnalyticsAction {
		case selectModel(name: String)
	}
}

struct StatusAdvisories: AnalyticsScreen {
	static let name = "Status Advisories"
	var action: Action
	enum Action: AnalyticsAction {
		case CallAdvisory
	}
}

struct FAQScreen: AnalyticsScreen {
	static let name = "FAQ"
	var action: Action
	enum Action: AnalyticsAction {}
}

enum UserProperty: AnalyticsUserProperty {
	case UserId(string: String)
	case NumberOfAircraft(count: Int)
	case NumberOfFlights(count: Int)
	
	var keyValue: [String: AnyObject] {
		switch self {
		case .UserId(string: let id):
			return ["user_id": id]
		case .NumberOfFlights(count: let count):
			return ["number_of_flights": count]
		case .NumberOfAircraft(count: let count):
			return ["number_of_aircraft": count]
		}
	}
}

public protocol SelfDescribable: CustomStringConvertible {}

extension SelfDescribable {
	public var description: String { return String(self) }
}
