//
//  AirMapTraffic.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/2/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper
import CoreLocation

@objc open class AirMapTraffic: NSObject {

	public enum TrafficType: Int {
		case alert
		case situationalAwareness
	}

	open var id: String!
	open var direction: Double = 0
	open var altitude: Double = 0
	open var groundSpeedKt: Double = 0
	open var trueHeading: Int = 0
	open var timestamp: Date = Date()
	open var recordedTime: Date = Date()
	open var properties = AirMapTrafficProperties()
	open var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
	open var initialCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
	open var createdAt: Date = Date()
	open var trafficType = TrafficType.situationalAwareness {
		willSet {
			trafficTypeDidChangeToAlert =  trafficType == .situationalAwareness && newValue == .alert
		}
	}
	open var trafficTypeDidChangeToAlert = false

	public override init() {
		super.init()
	}

	public required init?(map: Map) {}

	open func isExpired() -> Bool {
		let expirationInterval = Config.AirMapTraffic.expirationInterval
		return createdAt.addingTimeInterval(expirationInterval).lessThanDate(Date())
	}

	open override func isEqual(_ object: Any?) -> Bool {
		if let object = object as? AirMapTraffic {
			return object.properties.aircraftId == self.properties.aircraftId
		} else {
			return false
		}
	}
}

extension AirMapTraffic: Mappable {

	public func mapping(map: Map) {

		let dateTransform = CustomDateFormatTransform(formatString: Config.AirMapApi.dateFormat)

		id            <-  map["id"]
		direction     <- (map["direction"], StringToDoubleTransform())
		altitude      <- (map["altitude"], StringToDoubleTransform())
		groundSpeedKt <- (map["ground_speed_kts"], StringToDoubleTransform())
		trueHeading   <- (map["true_heading"], StringToIntTransform())
		properties    <-  map["properties"]
		timestamp     <- (map["timestamp"], dateTransform)
		recordedTime  <- (map["recorded_time"], dateTransform)

		var latitude: String!
		var longitude: String!
		latitude      <-  map["latitude"]
		longitude     <-  map["longitude"]

		if let lat = Double(latitude), let lng = Double(longitude) {
			initialCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
			coordinate = initialCoordinate
		}
	}
}

extension AirMapTraffic {

	open override var description: String {
		
		let lengthFormatter = LengthFormatter()
		lengthFormatter.unitStyle = .short

		let timeFormatter = DateComponentsFormatter()
		timeFormatter.allowsFractionalUnits = false
		timeFormatter.allowedUnits = [.minute, .second]
		timeFormatter.unitsStyle = .abbreviated

		let altitudeString: String
		let distanceString: String
		let groundSpeedString: String

		let groundSpeedFormat = NSLocalizedString("GROUND_SPEED_FORMAT", bundle: AirMapBundle.core, value: "%@ %@", comment: "Format for displaying ground speed")

		switch AirMap.configuration.distanceUnits {
		case .metric:
			altitudeString = lengthFormatter.string(fromValue: altitude, unit: .meter)
			let groundSpeedUnits = NSLocalizedString("GROUND_SPEED_UNIT_METERS_PER_SECOND", bundle: AirMapBundle.core, value: "m/s", comment: "Unit for displaying ground speed")
			groundSpeedString = String(format: groundSpeedFormat, groundSpeedKt, groundSpeedUnits)
		case .imperial:
			let miles = AirMapTrafficServiceUtils.metersToFeet(altitude)
			altitudeString = lengthFormatter.string(fromValue: altitude, unit: .foot)
			let groundSpeedUnits = NSLocalizedString("GROUND_SPEED_UNIT_KNOTS", bundle: AirMapBundle.core, value: "kts", comment: "Unit for displaying ground speed")
			groundSpeedString = String(format: groundSpeedFormat, groundSpeedKt, groundSpeedUnits)
		}
		
		let aircraftId = properties.aircraftId ?? ""

		if let flightLocation = AirMap.trafficService.currentFlightLocation() {

			let trafficLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
			let direction = flightLocation.initialDirectionToLocation(trafficLocation)
			
			let distance = trafficLocation.distance(from: flightLocation)
			let distanceString: String
			
			switch AirMap.configuration.distanceUnits {
			case .metric:
				distanceString = lengthFormatter.string(fromValue: distance, unit: .meter)
			case .imperial:
				let miles = AirMapTrafficServiceUtils.metersToFeet(altitude)
				distanceString = lengthFormatter.string(fromValue: miles, unit: .mile)
			}

			let seconds = Int(AirMapTrafficServiceUtils.secondsFromDistanceAndSpeed(distance, speedInKts: groundSpeedKt))
			let timeString = timeFormatter.string(from: DateComponents(second: seconds))!
			
			let alertFormat = NSLocalizedString(
				"TRAFFIC_ALERT_WITH_AIRCRAFT_ID_AND_DISTANCE_FORMAT",
				bundle: AirMapBundle.core,
				value: "Traffic %1$@\nAltitude %2$@\n%3$@ %4$@ %5$@",
				comment: "Format for traffic alerts. 1) aircraft id, 2) altitude, 3) distance, 4) direction, 5) time"
			)
			return String(format: alertFormat, aircraftId, altitudeString, distanceString, direction, timeString)
			
		} else {

			let alertFormat = NSLocalizedString(
				"TRAFFIC_ALERT_WITH_AIRCRAFT_ID_FORMAT",
				bundle: AirMapBundle.core,
				value: "Traffic %1$@\nAltitude %2$@\n%3$@",
				comment: "Format for traffic alerts. 1) aircraft id, 2) altitude, 3) ground speed"
			)
			return String(format: alertFormat, aircraftId, altitudeString, groundSpeedString)
		}
	}
}


















