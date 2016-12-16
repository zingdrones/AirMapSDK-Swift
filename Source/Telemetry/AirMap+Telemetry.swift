//
//  AirMap+Telemetry.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/28/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import AirMap
import ProtocolBuffers

private typealias AirMapTelemetryServices = AirMap
extension AirMapTelemetryServices {
	
	public enum TelemetryError: ErrorType {
		case InvalidCredentials
		case InvalidFlight
	}
	
	/**
	
	Send aircraft position telemetry data to AirMap
	
	- parameter flight: The `AirMapFlight` to report telemetry data for
	- parameter coordinate: The latitude & longitude of the aircraft
	- parameter altitude: The altitude of the aircraft in meters MSL
	
	*/
	public static func sendTelemetryData(flight: AirMapFlight, coordinate: CLLocationCoordinate2D, altitude: Float) throws {
		
		try canSendTelemetryFor(flight)
		
		let position = Airmap.Telemetry.Position.Builder()
		position.setLatitude(coordinate.latitude)
		position.setLongitude(coordinate.longitude)
		position.setAltitudeMMsl(altitude)
		position.setTimestamp(UInt64(NSDate().timeIntervalSince1970*1000))
		
		let positionMessage = try position.build()
		telemetryClient.sendTelemetry(flight, message: positionMessage)
	}
	
	/**
	
	Send aircraft speed telemetry data to AirMap
	
	- parameter flight: The `AirMapFlight` to report telemetry data for
	- parameter trueHeading: A direction that is measured in degrees relative to true north (0-360)
	- parameter groundSpeedMs: The speed at which the aircraft is moving in meters per second
	
	*/
	public static func sendTelemetryData(flight: AirMapFlight, groundSpeed: Float, trueHeading: Float) throws {
		
		try canSendTelemetryFor(flight)
		
		let speed = Airmap.Telemetry.Speed.Builder()
		speed.setGroundSpeedMs(groundSpeed)
		speed.setTrueHeading(trueHeading)
		speed.setTimestamp(UInt64(NSDate().timeIntervalSince1970*1000))

		let speedMessage = try speed.build()
		telemetryClient.sendTelemetry(flight, message: speedMessage)
	}
	
	/**
	
	Send barometer telemetry data to AirMap
	
	- parameter flight: The `AirMapFlight` to report telemetry data for
	- parameter baro: The barometric pressure in kPa (~1000)
	
	*/
	public static func sendTelemetryData(flight: AirMapFlight, baro: Float) throws {
		
		try canSendTelemetryFor(flight)
		
		let barometer = Airmap.Telemetry.Barometer.Builder()
		barometer.setBarometerHpa(baro)
		barometer.setTimestamp(UInt64(NSDate().timeIntervalSince1970*1000))

		let barometerMessage = try barometer.build()
		telemetryClient.sendTelemetry(flight, message: barometerMessage)
	}
	
	/**
	
	Verify the user can send telemetry data
	
	*/
	private static func canSendTelemetryFor(flight: AirMapFlight) throws {
	
		guard AirMap.hasValidCredentials() else {
			logger.error(self, "Please login before sending telemetry data.")
			throw TelemetryError.InvalidCredentials
		}
		
		guard flight.flightId != nil else {
			logger.error(self, "Flight must exist before sending telemetry data. Call \(#selector(AirMap.createFlight(flight:handler:))) before sending data.")
			throw TelemetryError.InvalidFlight
		}
	}
	
}
