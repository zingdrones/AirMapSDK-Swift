//
//  AirMapTraffic.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/2/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper
import CoreLocation

@objc public class AirMapTraffic: NSObject {

	public enum TrafficType: Int {
		case Alert
		case SituationalAwareness
	}

	public var id: String!
	public var direction: Double = 0
	public var altitude: Double = 0
	public var groundSpeedKt: Int = 0
	public var trueHeading: Int = 0
	public var timestamp: NSDate = NSDate()
	public var recordedTime: NSDate = NSDate()
	public var properties = AirMapTrafficProperties()
	public var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
	public var initialCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
	public var createdAt: NSDate = NSDate()
	public var trafficType = TrafficType.SituationalAwareness {
		willSet {
			trafficTypeDidChangeToAlert =  trafficType == .SituationalAwareness && newValue == .Alert
		}
	}
	public var trafficTypeDidChangeToAlert = false

	public override init() {
		super.init()
	}

	public required init?(_ map: Map) {}

	public func isExpired() -> Bool {
		let expirationInterval = Config.AirMapTraffic.expirationInterval
		return createdAt.dateByAddingTimeInterval(expirationInterval).lessThanDate(NSDate())
	}

	public override func isEqual(object: AnyObject?) -> Bool {
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
		groundSpeedKt <- (map["ground_speed_kts"], StringToIntTransform())
		trueHeading   <- (map["true_heading"], StringToIntTransform())
		properties    <-  map["properties"]
		timestamp     <- (map["timestamp"], dateTransform)
		recordedTime  <- (map["recorded_time"], dateTransform)

		var latitude: String!
		var longitude: String!
		latitude      <-  map["latitude"]
		longitude     <-  map["longitude"]

		if let lat = Double(latitude), lng = Double(longitude) {
			initialCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
			coordinate = initialCoordinate
		}
	}
}

extension AirMapTraffic {

	public override var description: String {
		
		let usesMetric = NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem)!.boolValue!
		let alt = usesMetric ? "\(Int(altitude)) m" : "\(Int(AirMapTrafficServiceUtils.metersToFeet(altitude))) ft"

		if let flightLocation = AirMap.trafficService.currentFlightLocation() {

			let trafficLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
			let direction = flightLocation.initialDirectionToLocation(trafficLocation)
			let distance = trafficLocation.distanceFromLocation(flightLocation)
			let milesOrMeters = usesMetric ?  "\(distance) m" : "\(AirMapTrafficServiceUtils.metersToMiles(distance)) mi"
			let seconds = AirMapTrafficServiceUtils.secondsFromDistanceAndSpeed(distance, speedInKts: groundSpeedKt)
			let (_, m, s) = seconds.secondsToHoursMinutesSeconds()
			let trafficTitle = properties.aircraftId == nil ? "Traffic" : "\(properties.aircraftId)"
			
			return "Traffic \(trafficTitle)\nAltitude \(alt)\n\(milesOrMeters) \(direction) \(m) min \(s) sec"
		}

		return "Traffic \(properties.aircraftId)\nAltitude \(alt)\n\(Int(groundSpeedKt))kts \(String.coordinateString(coordinate.latitude, longitude:coordinate.longitude) )"
	}
}
