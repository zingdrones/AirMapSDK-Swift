//
//  AirMapFlightAnnotation.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/25/17.
//

import Foundation
import Mapbox

/// NSObject wrapper for AirMapFlight
open class AirMapFlightAnnotation: NSObject {
	
	public let flight: AirMapFlight
	
	public init(_ flight: AirMapFlight) {
		self.flight = flight
	}
	
	override open func isEqual(_ object: Any?) -> Bool {
		guard let object = object as? AirMapFlightAnnotation else {
			return false
		}
		return self.flight == object.flight
	}
	
	override open var hashValue: Int {
		return flight.hashValue
	}
	
	static func ==(lhs: AirMapFlightAnnotation, rhs: AirMapFlightAnnotation) -> Bool {
		return lhs.flight.hashValue == rhs.flight.hashValue
	}
}

extension AirMapFlightAnnotation: MGLAnnotation {
	
	public var coordinate: CLLocationCoordinate2D {
		return flight.coordinate
	}
	
	public var title: String? {
		guard let startTime = flight.startTime else { return nil }
		let dateFormatter = DateFormatter()
		dateFormatter.doesRelativeDateFormatting = true
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .long
		return dateFormatter.string(from: startTime)
	}
}

extension AirMapFlightAnnotation: AnnotationRepresentable {
		
	var geometry: AirMapGeometry? {
		return flight.geometry
	}

}
