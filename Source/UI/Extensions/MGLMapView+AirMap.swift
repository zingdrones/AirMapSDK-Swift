//
//  MGLMapView+AirMap.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 10/7/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Mapbox
import GLKit

extension MGLMapView {
	
	func controlPointViews() -> [ControlPointView] {
		
		return subviews
			.filter { $0 is GLKView }.first?.subviews
			.filter { String(describing: type(of: $0)) == "MGLAnnotationContainerView"}.first?.subviews
			.flatMap { $0 as? ControlPointView } ?? []
	}
	
	func hideControlPoints(_ hidden: Bool) {
		
		let animations = { self.controlPointViews().forEach { $0.alpha = hidden ? 0 : 1 } }
		UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: animations, completion: nil)
	}
	
	func hideObscuredMidPointControls() {
		
		guard let annotations = annotations else { return }
		let controlPoints = annotations.flatMap { $0 as? ControlPoint }
		let midPoints = controlPoints.filter { $0.type == ControlPointType.midPoint }
		let vertexPoints = controlPoints.filter { $0.type == .vertex }
		
		for midPoint in midPoints {
			for vertex in vertexPoints {
				if distance(from: midPoint, to: vertex) < 40 {
					controlPointViews().filter { $0.annotation === midPoint }.first?.isHidden = true
					break
				} else {
					controlPointViews().filter { $0.annotation === midPoint }.first?.isHidden = false
				}
			}
		}
	}
	
	func distance(from pointA: ControlPoint, to pointB: ControlPoint) -> CGFloat {
		
		let ptA = convert(pointA.coordinate, toPointTo: self)
		let ptB = convert(pointB.coordinate, toPointTo: self)
		
		return hypot(ptA.x-ptB.x, ptA.y-ptB.y)
	}
	
}
