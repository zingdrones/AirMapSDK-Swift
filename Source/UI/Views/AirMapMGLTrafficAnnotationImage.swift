//
//  AirMapMGLTrafficAnnotationView.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/12/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Mapbox

public class AirMapMGLTrafficAnnotationImage : MGLAnnotationImage {

	public var traffic: AirMapTraffic! {
		willSet {
			traffic?.removeObserver(self, forKeyPath: "trueHeading")
			newValue?.addObserver(self, forKeyPath: "trueHeading", options: .New, context: nil)
		}
	}

	public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
		if let traffic = traffic where keyPath == "trueHeading" {
			image = AirMapImage.trafficIcon(traffic.trafficType, heading: traffic.trueHeading)!
		}
	}
	
	deinit {
		traffic?.removeObserver(self, forKeyPath: "trueHeading")
	}
}

public extension AirMapTraffic {
	
	public func mglAnnotationImage() -> AirMapMGLTrafficAnnotationImage {
		let icon = AirMapImage.trafficIcon(trafficType, heading: trueHeading)!
		let annotationImage =  AirMapMGLTrafficAnnotationImage(image: icon, reuseIdentifier: id)
		annotationImage.traffic = self
		return annotationImage
	}
}
