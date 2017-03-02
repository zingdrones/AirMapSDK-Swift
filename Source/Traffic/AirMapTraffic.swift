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

		let localizedUnits = LocalizedString.Units.self

		switch AirMap.configuration.distanceUnits {
		case .metric:
			let groundSpeedMps = AirMapTrafficServiceUtils.knotsToMetersPerSecond(knots: groundSpeedKt)
			groundSpeedString = String(format: localizedUnits.groundSpeedFormatMetersPerSecond, groundSpeedMps)
			altitudeString = lengthFormatter.string(fromValue: altitude, unit: .meter)
		case .imperial:
			let feet = AirMapTrafficServiceUtils.metersToFeet(altitude)
			groundSpeedString = String(format: localizedUnits.groundSpeedFormatKnots, groundSpeedKt)
			altitudeString = lengthFormatter.string(fromValue: feet, unit: .foot)
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
			
			let alertFormat = LocalizedString.Traffic.alertWithAircraftIdAndDistanceFormat
			return String(format: alertFormat, aircraftId, altitudeString, distanceString, direction, timeString)
			
		} else {

			let alertFormat = LocalizedString.Traffic.alertWithAircraftIdFormat
			return String(format: alertFormat, aircraftId, altitudeString, groundSpeedString)
		}
	}
}
