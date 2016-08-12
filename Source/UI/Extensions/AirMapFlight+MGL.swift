//
//  AirMapFlight+MGL.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/5/16.
//
//

import Mapbox

extension AirMapFlight: MGLAnnotation {
		
	public var title: String? {
		guard let startTime = startTime else { return nil }
		let dateFormatter = NSDateFormatter()
		dateFormatter.doesRelativeDateFormatting = true
		dateFormatter.dateStyle = .MediumStyle
		dateFormatter.timeStyle = .LongStyle
		return dateFormatter.stringFromDate(startTime)
	}
	
}
