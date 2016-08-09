//
//  AirMapTelemetry.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 5/26/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import CoreLocation
import CryptoSwift

@objc class AirMapTelemetry: NSObject {
	
	enum KeyState {
		case Retreiving
		case Finished
		case Unknown
	}
	
	/**
	Encoded Telemetry Data
	
	- parameter iv: [UInt8] Cyrtopgraphic initialization vector
	- parameter key: [UInt8] Cyrtopgraphic `Comm` key specific to the flight
	- parameter flightId: The `id` of the `AirMapFlight` associated with the data
	- parameter coordinate: Latitude and longitude of location
	- parameter altitude: Altitude
	- parameter trueHeading: True Heading (optional)
	- parameter groundSpeedMs: Ground Speed in Meters Per Second (optional)
	- parameter baro: Barometric Pressure (optional)
	- parameter timestamp: Time of data
	
	- returns: NSData?
	*/
	class func encodedTelemetryData(iv iv: [UInt8],
                                    key: [UInt8],
                                    flightId: String,
                                    coordinate: CLLocationCoordinate2D,
                                    altitude: Int?,
                                    groundSpeedMs: Int?,
                                    trueHeading: Int?,
                                    baro: Double?,
                                    timestamp: NSDate = NSDate()) -> NSData? {
		
		let secretMessage = SecretMessage.Builder()
		
		secretMessage.setLatitude(Float(coordinate.latitude))
			.setLongitude(Float(coordinate.longitude))
			.setTimestamp(UInt64(timestamp.timeIntervalSince1970))
		
		
		if let altitude = altitude {
			secretMessage.setAltitude(Int32(altitude))
		}
		
		if let groundSpeedMs = groundSpeedMs {
			secretMessage.setGroundSpeedMs(UInt32(groundSpeedMs))
		}
		
		if let trueHeading = trueHeading {
			secretMessage.setTrueHeading(UInt32(trueHeading))
		}
		
		if let baro = baro {
			secretMessage.setBaro(Float(baro))
		}
		
		do {
			let secretMessage = try secretMessage.build().data()
			let payload = AirMapTelemetry.encryptMessage(secretMessage, iv: iv, key: key)!
			let openMessage = OpenMessage.Builder()
			openMessage.setFlightId(flightId)
			openMessage.setPayload(payload)
			openMessage.setIv(dataFromIV(iv))
			
			return try openMessage.build().data()
			
		} catch {
			return nil
		}
	}
	
	/**
	Generates an AES initialization Vector
	
	- returns: [UInt8]
	*/
	class func generateIV() -> [UInt8] {
		return AES.randomIV(AES.blockSize)
	}
	
	/**
	Generates an NSData from an Initialization Vector
	
	- returns: NSData
	*/
	class func dataFromIV(iv: [UInt8]) -> NSData {
		return NSData(bytes: iv)
	}
	
	class func encryptMessage(data: NSData, iv: [UInt8], key: [UInt8]) -> NSData? {
		
		let count = data.length / sizeof(UInt8)
		var input = [UInt8](count: count, repeatedValue: 0)
		
		data.getBytes(&input, length: count * sizeof(UInt8))
		
		do {
			let encrypted: [UInt8] = try AES(key: key, iv: iv, blockMode: .CBC).encrypt(input)
			return NSData(bytes: encrypted)
		} catch {
			return nil
		}
	}
	
	class func decryptMessage(data: NSData, iv: [UInt8], key: [UInt8]) -> NSData? {
		
		let count = data.length / sizeof(UInt8)
		var input = [UInt8](count: count, repeatedValue: 0)
		
		data.getBytes(&input, length: count * sizeof(UInt8))
		
		do {
			let decrypted: [UInt8] = try AES(key: key, iv: iv, blockMode: .CBC).decrypt(input)
			return NSData(bytes: decrypted)
		} catch {
			return nil
		}
	}
}
