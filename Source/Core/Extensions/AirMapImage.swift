//
//  UIImage+AirMap.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/15/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

#if os(OSX)
	public typealias Image = NSImage
#else
	public typealias Image = UIImage
#endif

public class AirMapImage: NSObject {
	
	private override init() {
		super.init()
	}
	
	public class func image(named name: String) -> Image? {
		
		#if os(OSX)
			// FIXME:
			return nil
		#else
			return UIImage(named: name, inBundle: AirMapBundle.mainBundle(), compatibleWithTraitCollection: nil)
		#endif
	}

	public class func flightIcon(type: AirMapFlight.FlightType) -> Image? {

		switch type {
		case .Past :
			return image(named: "past_flight_marker_icon")
		case .Active:
			return image(named: "current_flight_marker_icon")
		case .Future:
			return image(named: "future_flight_marker_icon")
		}
	}
	
	#if AIRMAP_TRAFFIC
	public class func trafficIcon(type: AirMapTraffic.TrafficType, heading: Int) -> Image? {

		let direction = heading == 0 ? "" : "_" + AirMapTrafficServiceUtils.directionFromBearing(Double(heading))

		switch type {
		case .SituationalAwareness:
			return AirMapImage.image(named: "sa_traffic_marker_icon" + direction)
		case .Alert:
			return AirMapImage.image(named: "traffic_marker_icon" + direction)
		}
	}
	#endif

}
