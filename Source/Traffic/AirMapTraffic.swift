//
//  AirMapTraffic.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/2/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import CoreLocation

public class AirMapTraffic: NSObject, Codable {

	public enum TrafficType: Int, Codable {
		case alert
		case situationalAwareness
	}

	@objc public var id: String?
	@objc public var direction: Double = 0
	@objc public var altitude: Double = 0
	@objc public var groundSpeed: Knots = 0
	@objc public var trueHeading: Int = 0
	@objc public var timestamp: Date = Date()
	@objc public var recordedTime: Date = Date()
	@objc public var properties = AirMapTrafficProperties()
	@objc public var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
	@objc public var initialCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
	@objc public var createdAt: Date = Date()
	
	public var trafficType = TrafficType.situationalAwareness {
		willSet {
			trafficTypeDidChangeToAlert = trafficType == .situationalAwareness && newValue == .alert
		}
	}
	public var trafficTypeDidChangeToAlert = false

	public func isExpired() -> Bool {
		let expirationInterval = Constants.AirMapTraffic.expirationInterval
		return createdAt.addingTimeInterval(expirationInterval) < Date()
	}

	public override func isEqual(_ object: Any?) -> Bool {
		if let object = object as? AirMapTraffic {
			return object.properties.aircraftId == self.properties.aircraftId
		} else {
			return false
		}
	}

	public required init(from decoder: Decoder) throws {

		let container = try decoder.container(keyedBy: CodingKeys.self)

		enum CodingKeys: CodingKey {
			case id
			case direction
			case altitude
			case groundSpeedKts
			case trueHeading
			case timestamp
			case recordedTime
			case properties
			case coordinate
			case createdAt
			case latitude
			case longitude
		}

		id = try container.decode(String.self, forKey: .id)
		direction = try container.decode(Double.self, forKey: .direction)
		altitude = try container.decode(Double.self, forKey: .altitude)
		groundSpeed = try container.decode(Knots.self, forKey: .groundSpeedKts)
		trueHeading = try container.decode(Int.self, forKey: .trueHeading)
		timestamp = try container.decode(Date.self, forKey: .timestamp)
		recordedTime = try container.decode(Date.self, forKey: .recordedTime)
		properties = try container.decode(AirMapTrafficProperties.self, forKey: .properties)

		let latitude = try container.decode(String.self, forKey: .latitude)
		let longitude = try container.decode(String.self, forKey: .longitude)

		if let lat = Double(latitude), let lon = Double(longitude) {
			initialCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
			coordinate = initialCoordinate
		}
	}

}

extension AirMapTraffic {

	public override var description: String {
		
		let lengthFormatter = LengthFormatter()
		lengthFormatter.unitStyle = .medium
		lengthFormatter.numberFormatter.maximumFractionDigits = 0

		let timeFormatter = DateComponentsFormatter()
		timeFormatter.allowsFractionalUnits = false
		timeFormatter.allowedUnits = [.minute, .second]
		timeFormatter.unitsStyle = .abbreviated
		
		let speedFormatter = NumberFormatter()
		speedFormatter.maximumFractionDigits = 0
		
		let altitudeString: String
		let localizedGroundSpeedString: String

		let localizedUnits = LocalizedStrings.Units.self

		lengthFormatter.numberFormatter.roundingIncrement = 50
		switch AirMap.configuration.distanceUnits {
		case .metric:
			let meters = altitude.meters
			let groundSpeedMpsString = speedFormatter.string(from: NSNumber(value: groundSpeed.metersPerSecond))!
			localizedGroundSpeedString = String(format: localizedUnits.speedFormatMetersPerSecond, groundSpeedMpsString)
			altitudeString = lengthFormatter.string(fromValue: meters, unit: .meter)
		case .imperial:
			let feet = altitude
			let groundSpeedKnotsString = speedFormatter.string(from: NSNumber(value: groundSpeed))!
			localizedGroundSpeedString = String(format: localizedUnits.speedFormatKnots, groundSpeedKnotsString)
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
				if distance < 950 {
					lengthFormatter.numberFormatter.roundingIncrement = 100
					lengthFormatter.numberFormatter.maximumFractionDigits = 0
					distanceString = lengthFormatter.string(fromValue: distance, unit: .meter)
				} else {
					lengthFormatter.numberFormatter.roundingIncrement = 0.5
					lengthFormatter.numberFormatter.maximumFractionDigits = 1
					distanceString = lengthFormatter.string(fromValue: distance/1000, unit: .kilometer)
				}
			case .imperial:
				lengthFormatter.numberFormatter.roundingIncrement = 0.5
				lengthFormatter.numberFormatter.maximumFractionDigits = 1
				let miles = distance.nauticalMiles
				distanceString = lengthFormatter.string(fromValue: miles, unit: .mile)
			}

			// Set timeString to an empty value
			var timeString = ""
			
			// GroundSpeed must be grater than zero when calculating secondsFromDistanceAndSpeed
			if groundSpeed > 0 {
				let seconds = Int(AirMapTrafficServiceUtils.secondsFromDistanceAndSpeed(distance, speedInKts: groundSpeed))
				timeString = timeFormatter.string(from: DateComponents(second: seconds))!
			}
			
			let alertFormat = LocalizedStrings.Traffic.alertWithAircraftIdAndDistanceFormat
			return String(format: alertFormat, aircraftId, altitudeString, distanceString, direction, timeString)
			
		} else {

			let alertFormat = LocalizedStrings.Traffic.alertWithAircraftIdFormat
			return String(format: alertFormat, aircraftId, altitudeString, localizedGroundSpeedString)
		}
	}
}
