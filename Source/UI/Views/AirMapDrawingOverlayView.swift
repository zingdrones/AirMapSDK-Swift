//
//  AirMapDrawingOverlayView.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/6/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit
import SwiftSimplify

protocol DrawingOverlayDelegate: class {
	func overlayDidDraw(geometry: [CGPoint])
}

class AirMapDrawingOverlayView: UIView {
	
	weak var delegate: DrawingOverlayDelegate?
	
	var tolerance: Float = 10
	var discardsDuplicateClosingPoint = false
	
	private var points = [CGPoint]() {
		didSet { setNeedsDisplay() }
	}
		
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		
		points = []

		let point = touches.first!.location(in: self)
		points.append(point)
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		
		let point = touches.first!.location(in: self)
		points.append(point)
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		
		let point = touches.first!.location(in: self)
		points.append(point)

		points = SwiftSimplify.simplify(points, tolerance: tolerance, highQuality: true)

		if discardsDuplicateClosingPoint {
			discardDuplicateClosingPoint(within: tolerance*2)
		}

		delegate?.overlayDidDraw(geometry: points)
		
		points = []
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		
		touchesEnded(touches, with: event)
	}
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		
		let cgPath = CGMutablePath()
		cgPath.addLines(between: points)
		
		UIColor.airMapDarkGray.setStroke()
		
		let uiPath = UIBezierPath(cgPath: cgPath)
		uiPath.setLineDash([6], count: 1, phase: 0)
		uiPath.lineWidth = 2.5
		uiPath.miterLimit = 2
		uiPath.lineJoinStyle = .round
		uiPath.stroke()
	}
	
	private func discardDuplicateClosingPoint(within tolerance: Float) {
		
		guard points.count >= 2 else { return }
		
		let first = points.first!
		let last = points.last!
		
		let distance = Float(hypot(first.x-last.x, first.y-last.y))
		if distance < tolerance {
			points.removeLast()
		}
	}

}
