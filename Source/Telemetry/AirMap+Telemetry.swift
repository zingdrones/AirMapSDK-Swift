//
//  AirMap+Telemetry.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/28/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift

private typealias AirMapTelemetryServices = AirMap
extension AirMapTelemetryServices {

	/**

	Send aircraft telemetry data to AirMap

	- parameter flight: The `AirMapFlight` to report telemetry data for
	- parameter coordinate: The latitude & longitude of the aircraft
	- parameter altitude: The altitude of the aircraft AGL
	- parameter trueHeading: Optional, a direction that is measured in degrees relative to true north
	- parameter groundSpeedMs: Optional, the speed at which the aircraft is moving in meters per second
	- parameter baro: Optional, the barometric pressure

	*/
	public static func sendTelemetryData(flight: AirMapFlight,
	                                     coordinate: CLLocationCoordinate2D,
	                                     altitude: Int,
	                                     groundSpeed: Int?,
	                                     trueHeading: Int?,
	                                     baro: Double?) {

		guard AirMap.hasValidCredentials() else {
			logger.error(AirMap.self, "Call \(#selector(AirMap.configure(apiKey:pinCertificates:))) before sending telemetry data.")
			return
		}

		guard flight.flightId != nil  else {
			logger.error(AirMap.self, "Flight must exist before sending telemetry data. Call \(#selector(AirMap.createFlight(flight:handler:))) AirMap.createFlight(: ...) before sending data.")
			return
		}

		guard CLLocationCoordinate2DIsValid(coordinate) else { return }

		guard telemetrySocket.keyState != .Retreiving else { return }

		telemetrySocket.retreiveCommunicationKey(flight)
			.doOnNext { comm in
				if let telemetryData = AirMapTelemetry.encodedTelemetryData(
					iv: AirMapTelemetry.generateIV(),
					key: comm.binaryKey(),
					flightId: flight.flightId,
					coordinate: coordinate,
					altitude: altitude,
					groundSpeedMs: groundSpeed,
					trueHeading: trueHeading,
					baro: baro) {
					telemetrySocket.sendMessage(telemetryData)
				}
			}
			.doOnError { error in
				logger.error("Error retreiving comm key for flight", (error as NSError).localizedDescription)
			}
			.subscribe()
			.addDisposableTo(disposeBag)
	}

}
