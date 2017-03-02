//
//  LocalizedString.swift
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
	
	struct TileLayer {
		
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
			value: "Schools",
			comment: "Name for map layer Schools")
		
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
	
	struct Auth {
		
		static let unauthorized = NSLocalizedString(
			"AUTH_ERROR_UNAUTHORIZED", bundle: bundle,
			value: "Unauthorized",
			comment: "Login message when a user failed to authenticate")
		
		static let emailVerificationRequired = NSLocalizedString(
			"AUTH_ERROR_EMAIL_NEEDS_VERIFICATION_REQUIRED", bundle: bundle,
			value: "Your email address needs to be verified. Please check your inbox.",
			comment: "Login message when a user must verify their email address")
		
		static let domainBlacklisted = NSLocalizedString(
			"AUTH_ERROR_ACCOUNT_BLACKLISTED", bundle: bundle,
			value: "Your account has been blacklisted. Please contact security@airmap.com",
			comment: "Login message when a user's account has been blacklisted.")
		
		static let failedLoginTitle = NSLocalizedString(
			"AUTH_FAILED_LOGIN_TITLE", bundle: bundle,
			value: "Alert",
			comment: "Navigation title for failed login attempt")
	}
	
	struct Advisory {
		
		static let phoneNumberNotProvided = NSLocalizedString(
			"ADVISORY_PHONE_NOT_PROVIDED", bundle: bundle,
			value: "No Phone Number Provided",
			comment: "Displayed when an advisory has not provided a contact phone")
		
		static let tfrStartsFormat = NSLocalizedString(
			"ADVISORY_TFR_STARTS_FORMAT", bundle: bundle,
			value: "Starts: %1$@",
			comment: "Label and format for displaying the start time of temporary flight restriction")

		static let tfrEndsFormat = NSLocalizedString(
			"ADVISORY_TFR_ENDS_FORMAT", bundle: bundle,
			value: "Ends: %1$@",
			comment: "Label and format for displaying the end time of temporary flight restriction")

		static let tfrPermanent = NSLocalizedString(
			"ADVISORY_TFR_PERMANENT", bundle: bundle,
			value: "Permanent",
			comment: "Never ending duration for a TFR")
		
		static let wildfireSizeFormatAcres = NSLocalizedString(
			"ADVISORY_WILDFIRE_SIZE_FORMAT_ACRES", bundle: bundle,
			value: "%$1@ Acres",
			comment: "Format and unit for wildfire advisory in the area unit acres")

		static let wildfireSizeFormatHectares = NSLocalizedString(
			"ADVISORY_WILDFIRE_SIZE_FORMAT_HECTARES", bundle: bundle,
			value: "%$1@ Hectares",
			comment: "Format and unit for wildfire advisory in the area unit hectares")
		
		static let wildfireSizeUnknown = NSLocalizedString(
			"ADVISORY_WILDFIRE_SIZE_UNKNOWN", bundle: bundle,
			value: "Size Unknown",
			comment: "Label for wildfire advisory cells where size is unknown")
		
		static let acceptsDigitalNotice = NSLocalizedString(
			"ADVISORY_ACCEPTS_DIGITAL_NOTICE", bundle: bundle,
			value: "Accepts Digital Notice",
			comment: "Label for advisories that are stup to receive digital notice")
	}
	
	struct FlightDrawing {
		
		static let width = NSLocalizedString(
			"FLIGHT_DRAWING_WIDTH", bundle: bundle,
			value: "Width",
			comment: "The width of a path-based flight extending outward from the centerline")
		
		static let radius = NSLocalizedString(
			"FLIGHT_DRAWING_RADIUS", bundle: bundle,
			value: "Radius",
			comment: "The radius around a point-based flight's center")
		
		static let tooltipErrorOverlappingPermitAreas = NSLocalizedString(
			"FLIGHT_DRAWING_TOOLTIP_ERROR_OVERLAPPING_PERMIT_AREAS", bundle: bundle,
			value: "Flight area cannot overlap with conflicting permit requirement zones.",
			comment: "Displayed when the user has drawn an invalid shaping, overlapping with conflicting permitted zones")
		
		static let tooltipErrorSelfIntersectingGeometry = NSLocalizedString(
			"FLIGHT_DRAWING_TOOLTIP_ERROR_SELF_INTERSECTING_GEOMETRY", bundle: bundle,
			value: "Invalid flight area. Adjust flight area so that it does not overlap with itself.",
			comment: "Call to action to fix self-intersecting geometries of an area-based flight.")
		
		static let toolTipCtaDrawFreehandPath = NSLocalizedString(
			"FLIGHT_DRAWING_TOOLTIP_CTA_DRAW_FREEHAND_PATH", bundle: bundle,
			value: "Draw a freehand path",
			comment: "Call to action to draw a path-based flight.")
		
		static let toolTipCtaDrawFreehandArea = NSLocalizedString(
			"FLIGHT_DRAWING_TOOLTIP_CTA_DRAW_FREEHAND_AREA", bundle: bundle,
			value: "Draw a freehand area",
			comment: "Call to action to draw an area-based flight.")
		
		static let toolTipCtaTapToDrawPath = NSLocalizedString(
			"FLIGHT_DRAWING_TOOLTIP_CTA_TAP_ICON_TO_DRAW_PATH", bundle: bundle,
			value: "Tap the hand icon to freehand draw any path.",
			comment: "Call to action to tap the icon to begin drawing a flight path.")
		
		static let toolTipCtaDragPointToModifyGeometry = NSLocalizedString(
			"FLIGHT_DRAWING_TOOLTIP_CTA_DRAG_TO_MODIFY_GEOMETRY", bundle: bundle,
			value: "Drag any point to move. Drag any midpoint to add a new point.",
			comment: "Call to action to fine-tune the geometry of a flight.")
		
		static let toolTipCtaTapToDrawArea = NSLocalizedString(
			"FLIGHT_DRAWING_TOOLTIP_CTA_TAP_ICON_TO_DRAW_AREA", bundle: bundle,
			value: "Tap the hand icon to freehand draw any area.",
			comment: "Call to action to tap the icon to begin drawing a flight area.")
		
		static let toolTipCtaTapToDrawPoint = NSLocalizedString(
			"FLIGHT_DRAWING_TOOLTIP_CTA_POSTIION_POINT", bundle: bundle,
			value: "Drag the center point to position your flight area.",
			comment: "Call to action to drag the center position of a point-based flight.")
		
		static let toolTipCtaDragToTrashToDelete = NSLocalizedString(
			"FLIGHT_DRAWING_TOOLTIP_CTA_DRAG_TO_TRASH_TO_DELETE", bundle: bundle,
			value: "Drag point to trash to delete",
			comment: "Call to action to drag a point to the trash to delete.")
	}
	
	struct FlightPlan {
		
		static let sectionHeaderFlight = NSLocalizedString(
			"FLIGHT_PLAN_SECTION_HEADER_FLIGHT", bundle: bundle,
			value: "Flight",
			comment: "Title for the section displaying flight plan details")
		
		static let sectionHeaderFlightTime = NSLocalizedString(
			"FLIGHT_PLAN_SECTION_HEADER_TIME", bundle: bundle,
			value: "Date & Time",
			comment: "Title for the section displaying flight plan start time & duration")
		
		static let sectionHeaderAssociated = NSLocalizedString(
			"FLIGHT_PLAN_SECTION_HEADER_ASSOCIATED", bundle: bundle,
			value: "Pilot & Aircraft",
			comment: "Title for the section displaying the pilot and aircraft details")
		
		static let sectionHeaderSocial = NSLocalizedString(
			"FLIGHT_PLAN_SECTION_HEADER_SHARE", bundle: bundle,
			value: "Share My Flight",
			comment: "Title for the section displaying social sharing features")
		
		static let rowTitleAltitude = NSLocalizedString(
			"FLIGHT_PLAN_ROW_TITLE_ALTITUDE", bundle: bundle,
			value: "Altitude",
			comment: "Title for the row displaying flight plan altitude")
		
		static let rowTitleStartTime = NSLocalizedString(
			"FLIGHT_PLAN_ROW_TITLE_START_TIME", bundle: bundle,
			value: "Starts",
			comment: "Title for the row displaying flight plan start time")
		
		static let rowTitleDuration = NSLocalizedString(
			"FLIGHT_PLAN_ROW_TITLE_DURATION", bundle: bundle,
			value: "Duration",
			comment: "Title for the row displaying flight plan duration")
		
		static let rowTitlePilot = NSLocalizedString(
			"FLIGHT_PLAN_ROW_TITLE_PILOT", bundle: bundle,
			value: "Select Pilot Profile",
			comment: "Call to action title for the user to select a pilot profile")
		
		static let rowTitleAircraft = NSLocalizedString(
			"FLIGHT_PLAN_ROW_TITLE_AIRCRAFT", bundle: bundle,
			value: "Select Aircraft",
			comment: "Call to action title for the user to select an aircraft")
		
		static let buttonTitleNext = NSLocalizedString(
			"FLIGHT_PLAN_BUTTON_TITLE_NEXT", bundle: bundle,
			value: "Next",
			comment: "Title for the button to advance to the next screen")
		
		static let buttonTitleSave = NSLocalizedString(
			"FLIGHT_PLAN_BUTTON_TITLE_SAVE", bundle: bundle,
			value: "Save",
			comment: "Title for the button to save and create the flight")
	}
	
	struct ReviewFlightPlan {
		
		static let tabTitleFlight = NSLocalizedString(
			"REVIEW_FLIGHT_PLAN_TAB_TITLE_FLIGHT", bundle: bundle,
			value: "Flight",
			comment: "Title for the Review Flight, flight Details tab")
		
		static let tabTitlePermits = NSLocalizedString(
			"REVIEW_FLIGHT_PLAN_TAB_TITLE_PERMITS", bundle: bundle,
			value: "Permits",
			comment: "Title for the Review Flight, permits tab")
		
		static let tabTitleNotices = NSLocalizedString(
			"REVIEW_FLIGHT_PLAN_TAB_TITLE_DIGITAL_NOTICE", bundle: bundle,
			value: "Notices",
			comment: "Title for the Review Flight, digital notices tab")
	}
	
	struct ReviewFlightPlanDetails {
		
		static let startTimeNow = NSLocalizedString(
			"REVIEW_FLIGHT_PLAN_DETAILS_START_TIME_NOW", bundle: bundle,
			value: "Now",
			comment: "Time for flights that start immediately")
		
		static let sectionHeaderDetails = NSLocalizedString(
			"REVIEW_FLIGHT_PLAN_DETAILS_SECTION_HEADER_DETAILS", bundle: bundle,
			value: "Details",
			comment: "Header label for the flight review details section")
		
		static let sectionHeaderAircraft = NSLocalizedString(
			"REVIEW_FLIGHT_PLAN_DETAILS_SECTION_HEADER_AIRCRAFT", bundle: bundle,
			value: "Aircraft",
			comment: "Header label for the flight review aircraft section")
		
		static let sectionHeaderSocial = NSLocalizedString(
			"REVIEW_FLIGHT_PLAN_DETAILS_SECTION_HEADER_SOCIAL", bundle: bundle,
			value: "Share My Flight",
			comment: "Header label for the flight review social sharing section")

		static let rowLabelAircraft = NSLocalizedString(
			"REVIEW_FLIGHT_PLAN_DETAILS_ROW_TITLE_AIRCRAFT", bundle: bundle,
			value: "Aircraft",
			comment: "Label for the aircraft row")
		
		static let rowTitleRadius = NSLocalizedString(
			"REVIEW_FLIGHT_PLAN_DETAILS_RADIUS", bundle: bundle,
			value: "Radius",
			comment: "Label for the Buffer or radius surrounding a point or path")
		
		static let rowTitleAltitude = NSLocalizedString(
			"REVIEW_FLIGHT_PLAN_DETAILS_ROW_TITLE_ALTITUDE", bundle: bundle,
			value: "Altitude",
			comment: "Label for the maximum altitude for a flight")
		
		static let rowTitleStarts = NSLocalizedString(
			"REVIEW_FLIGHT_PLAN_DETAILS_ROW_TITLE_STARTS", bundle: bundle,
			value: "Starts",
			comment: "Label for a flight's start time")
		
		static let rowTitleEnds = NSLocalizedString(
			"REVIEW_FLIGHT_PLAN_DETAILS_ROW_TITLE_ENDS", bundle: bundle,
			value: "Ends",
			comment: "Label for a flight's end time")
		
		static let rowTitleDuration = NSLocalizedString(
			"REVIEW_FLIGHT_PLAN_DETAILS_ROW_TITLE_DURATION", bundle: bundle,
			value: "Ends",
			comment: "Label for a flight's duration")
		
		static let rowTitlePublic = NSLocalizedString(
			"REVIEW_FLIGHT_PLAN_DETAILS_ROW_TITLE_PUBLIC", bundle: bundle,
			value: "Public",
			comment: "Label for the flight review 'is public' row")
		
		static let yes = NSLocalizedString(
			"REVIEW_FLIGHT_PLAN_DETAILS_PUBLIC_FLIGHT_VALUE_TRUE", bundle: bundle,
			value: "Yes",
			comment: "'Yes' Value for the public flight row")
	}
	
	struct ReviewFlightPlanNotices {
		
		static let headerNoNotices = NSLocalizedString(
			"REVIEW_FLIGHT_PLAN_NOTICES_TAB_SECTION_HEADER_NO_NOTICES", bundle: bundle,
			value: "There are no notices for this flight.",
			comment: "Displayed in the flight plan review notices tab when there are no notices to display")

		static let acceptsDigitalNotice = NSLocalizedString(
			"REVIEW_FLIGHT_PLAN_NOTICES_TAB_ACCEPTS_NOTICE", bundle: bundle,
			value: "Accepts Digital Notice",
			comment: "Displayed for authorities that are setup to receive digital notice")
		
		static let doesNotacceptsDigitalNotice = NSLocalizedString(
			"REVIEW_FLIGHT_PLAN_NOTICES_TAB_DOES_NOT_ACCEPT_NOTICE", bundle: bundle,
			value: "The following authorities in this area do not accept digital notice",
			comment: "Displayed for authorities that are NOT setup to receive digital notice")
	}
	
	struct Rules {
		
		static let genericTitle = NSLocalizedString(
			"RULES_GENERIC_TITLE", bundle: bundle,
			value: "Locality Rules",
			comment: "Title for the Local Rules view when a locality name is unavailable")
	}
	
	struct PilotProfile {
		
		static let faaRegistrationLabel = NSLocalizedString(
			"PILOT_PROFILE_FAA_REGISTRATION", bundle: bundle,
			value: "FAA Registration Number",
			comment: "Table row label for FAA registration number")
		
		static let firstNameLabel = NSLocalizedString(
			"PILOT_PROFILE_LABEL_FIRST_NAME", bundle: bundle,
			value: "First Name",
			comment: "Label for the pilot profile first name")
	
		static let lastNameLabel = NSLocalizedString(
			"PILOT_PROFILE_LABEL_LAST_NAME", bundle: bundle,
			value: "Last Name",
			comment: "Label for the pilot profile last name")

		static let usernameLabel = NSLocalizedString(
			"PILOT_PROFILE_LABEL_USERNAME", bundle: bundle,
			value: "Username",
			comment: "Label for the pilot profile username")
		
		static let emailLabel = NSLocalizedString(
			"PILOT_PROFILE_LABEL_EMAIL", bundle: bundle,
			value: "Email",
			comment: "Label for the pilot profile email")
		
		static let phoneLabel = NSLocalizedString(
			"PILOT_PROFILE_LABEL_PHONE", bundle: bundle,
			value: "Phone",
			comment: "Label for the pilot profile phone")
	
		static let sectionHeaderPersonal = NSLocalizedString(
			"PILOT_PROFILE_SECTION_PERSONAL", bundle: bundle,
			value: "Personal Info",
			comment: "Section header for the pilot profile personal info section")
		
		static let sectionHeaderAdditional = NSLocalizedString(
			"PILOT_PROFILE_SECTION_ADDITIONAL", bundle: bundle,
			value: "Additional Info",
			comment: "Section header for the pilot profile additional info section")
		
		static let statisticsFormat = NSLocalizedString(
			"PILOT_PROFILE_STATISTICS_FORMAT", bundle: bundle,
			value: "%1$@ Aircraft, %2$@ Flights",
			comment: "Format for displaying a user's number of aircraft and flights")
	}
	
	struct PhoneCountry {
	
		static let selectedCountry = NSLocalizedString(
			"PHONE_COUNTRY_SECTION_SELECTED_COUNTRY", bundle: bundle,
			value: "Selected Country",
			comment: "Table section title for the currently selected country")
		
		static let otherCountry = NSLocalizedString(
			"PHONE_COUNTRY_SECTION_OTHER_COUNTRY", bundle: bundle,
			value: "Other",
			comment: "Table section title for other selectable countries")
	}
	
	struct RequiredPermits {
		
		static let selectPermit = NSLocalizedString(
			"REQUIRED_PERMITS_SELECT_PERMIT", bundle: bundle,
			value: "Select permit",
			comment: "Call to action row text for selecting a permit")
		
		static let selectDifferentPermit = NSLocalizedString(
			"REQUIRED_PERMITS_SELECT_DIFFERENT_PERMIT", bundle: bundle,
			value: "Select a different permit",
			comment: "Call to action row text for selecting a different permit than the one displayed above")
	}
	
	struct AvailablePermits {
		
		static let sectionHeaderExisting = NSLocalizedString(
			"AVAILABLE_PERMITS_SECTION_HEADER_EXISTING", bundle: bundle,
			value: "Existing Permits",
			comment: "Title for table section header of existing permits the user has")
		
		static let sectionHeaderAvailable = NSLocalizedString(
			"AVAILABLE_PERMITS_SECTION_HEADER_AVAILABLE", bundle: bundle,
			value: "Available Permits",
			comment: "Title for table section header of available permits the user may apply for")
		
		static let sectionHeaderUnavailable = NSLocalizedString(
			"AVAILABLE_PERMITS_SECTION_HEADER_UNAVAILABLE", bundle: bundle,
			value: "Unavailable Permits",
			comment: "Title for table section header of permits which are not available to the user")
		
		static let tableHeaderAvailablePermits = NSLocalizedString(
			"AVAILABLE_PERMITS_TABLE_HEADER", bundle: bundle,
			value: "The following existing & available permits meets the requirements for operation in the flight area.",
			comment: "Header copy describing the permits listed below")
		
		static let tableHeaderConflictingRequirements = NSLocalizedString(
			"AVAILABLE_PERMITS_TABLE_HEADER_CONFLICTING_REQUIREMENTS", bundle: bundle,
			value: "Only a single permit can be used to fly in this operating area. Your flight path intersects with multiple areas requiring different permits.",
			comment: "Header copy describing that the flight area overlaps with multiple areas, each with differing permit requirements. No one single permit is able to satisfy all requirements.")
	}
	
	struct AvailablePermit {
		
		static let sectionHeaderDescription = NSLocalizedString(
			"AVAILABLE_PERMIT_SECTION_HEADER_DESCRIPTION", bundle: bundle,
			value: "Description",
			comment: "Title for the Description section of the permit detail view")
		
		static let rowTitleValidity = NSLocalizedString(
			"AVAILABLE_PERMIT_ROW_TITLE_VALIDITY", bundle: bundle,
			value: "Valid for",
			comment: "Title for the row that shows the temporal validity or expiration of the permit")
		
		static let rowTitleSingleUse = NSLocalizedString(
			"AVAILABLE_PERMIT_ROW_TITLE_SINGLE_USE", bundle: bundle,
			value: "Single use",
			comment: "Title for the row that describes if the permit can be used more than once.")
		
		static let rowValueSingleUseValueTrue = NSLocalizedString(
			"AVAILABLE_PERMIT_ROW_VALUE_SINGLE_USE_TRUE", bundle: bundle,
			value: "Yes",
			comment: "Value for when single use is true")
		
		static let rowValueSingleUseValueFalse = NSLocalizedString(
			"AVAILABLE_PERMIT_ROW_VALUE_SINGLE_USE_FALSE", bundle: bundle,
			value: "No",
			comment: "Value for when single use is false")
		
		static let rowTitleDetails = NSLocalizedString(
			"AVAILABLE_PERMIT_SECTION_HEADER_DETAILS", bundle: bundle,
			value: "Details",
			comment: "Title for the Details section of the permit detail view")
		
		static let sectionHeaderCustomProperties = NSLocalizedString(
			"AVAILABLE_PERMIT_SECTION_HEADER_CUSTOM_PROPERTIES", bundle: bundle,
			value: "Form Fields (* Required)",
			comment: "Title for the Custom Properties section of the permit detail view. '*' denotes a required field")
	}
	
	struct PilotPermit {
		
		static let expirationFormat = NSLocalizedString(
			"PILOT_PERMIT_EXPIRATION_FORMAT", bundle: bundle,
			value: "Expires %$1@",
			comment: "Format for pilot permit expiration")
	}
	
	struct Aircraft {
		
		static let titleCreate = NSLocalizedString(
			"AIRCRAFT_TITLE_CREATE_NEW", bundle: bundle,
			value: "Create Aircraft",
			comment: "Title to display for the view creating a new aircraft")
		
		static let titleUpdate = NSLocalizedString(
			"AIRCRAFT_TITLE_UPDATE_EXISTING", bundle: bundle,
			value: "Update Aircraft",
			comment: "Title to display for the view when updating an existing aircraft")
		
		static let selectAircraft = NSLocalizedString(
			"AIRCRAFT_SELECT_AIRCRAFT", bundle: bundle,
			value: "Select Aircraft",
			comment: "Call to action when a user has not selected an aircraft")
	}
	
	struct CardinalDirection {
		
		static let N   = NSLocalizedString(
			"CARDINAL_DIRECTION_N",    bundle: bundle,
			value: "N",   comment: "Abbreviation for North")
		static let NNE = NSLocalizedString(
			"CARDINAL_DIRECTION_NNNE", bundle: bundle,
			value: "NNE",
			comment: "Abbreviation for North North East")
		static let NE  = NSLocalizedString(
			"CARDINAL_DIRECTION_NE",   bundle: bundle,
			value: "NE",  comment: "Abbreviation for North East")
		static let ENE = NSLocalizedString(
			"CARDINAL_DIRECTION_ENE",  bundle: bundle,
			value: "ENE",
			comment: "Abbreviation for East North East")
		static let E   = NSLocalizedString(
			"CARDINAL_DIRECTION_E",    bundle: bundle,
			value: "E",   comment: "Abbreviation for East")
		static let ESE = NSLocalizedString(
			"CARDINAL_DIRECTION_ESE",  bundle: bundle,
			value: "ESE",
			comment: "Abbreviation for East South East")
		static let SE  = NSLocalizedString(
			"CARDINAL_DIRECTION_SE",   bundle: bundle,
			value: "SE",  comment: "Abbreviation for South East")
		static let SSE = NSLocalizedString(
			"CARDINAL_DIRECTION_SSE",  bundle: bundle,
			value: "SSE",
			comment: "Abbreviation for South South East")
		static let S   = NSLocalizedString(
			"CARDINAL_DIRECTION_S",    bundle: bundle,
			value: "S",   comment: "Abbreviation for South")
		static let SSW = NSLocalizedString(
			"CARDINAL_DIRECTION_SSW",  bundle: bundle,
			value: "SSW",
			comment: "Abbreviation for South South West")
		static let SW  = NSLocalizedString(
			"CARDINAL_DIRECTION_SW",   bundle: bundle,
			value: "SW",  comment: "Abbreviation for South West")
		static let WSW = NSLocalizedString(
			"CARDINAL_DIRECTION_WSW",  bundle: bundle,
			value: "WSW",
			comment: "Abbreviation for West South West")
		static let W   = NSLocalizedString(
			"CARDINAL_DIRECTION_W",    bundle: bundle,
			value: "W",   comment: "Abbreviation for West")
		static let WNW = NSLocalizedString(
			"CARDINAL_DIRECTION_WNW",  bundle: bundle,
			value: "WNW",
			comment: "Abbreviation for West North West")
		static let NW  = NSLocalizedString(
			"CARDINAL_DIRECTION_NW",   bundle: bundle,
			value: "NW",  comment: "Abbreviation for North West")
		static let NNW = NSLocalizedString(
			"CARDINAL_DIRECTION_NNW",  bundle: bundle,
			value: "NNW",
			comment: "Abbreviation for North North West")
	}
	
	struct Units {
		
		static let groundSpeedFormatMetersPerSecond = NSLocalizedString(
			"UNITS_GROUND_SPEED_UNIT_METERS_PER_SECOND", bundle: bundle,
			value: "%@ m/s",
			comment: "Unit and format for displaying ground speed in meters per second")
		
		static let groundSpeedFormatKnots = NSLocalizedString(
			"UNITS_GROUND_SPEED_UNIT_KNOTS", bundle: bundle,
			value: "%@ kts",
			comment: "Unit and format for displaying ground speed in knots")
	}
	
	struct Traffic {
		
		static let alertWithAircraftIdFormat = NSLocalizedString(
			"TRAFFIC_ALERT_WITH_AIRCRAFT_ID_FORMAT", bundle: bundle,
			value: "Traffic %1$@\nAltitude %2$@\n%3$@",
			comment: "Format for traffic alerts. 1) aircraft id, 2) altitude, 3) ground speed"
		)
		
		static let alertWithAircraftIdAndDistanceFormat = NSLocalizedString(
			"TRAFFIC_ALERT_WITH_AIRCRAFT_ID_AND_DISTANCE_FORMAT",
			bundle: bundle,
			value: "Traffic %1$@\nAltitude %2$@\n%3$@ %4$@ %5$@",
			comment: "Format for traffic alerts. 1) aircraft id, 2) altitude, 3) distance, 4) direction, 5) time"
		)
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
