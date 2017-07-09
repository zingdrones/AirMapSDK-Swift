//
//  AirMapEditingOverlayView.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit

class AirMapEditingOverlayView: UIView {
	
	private var points = [[CGPoint]]() {
		didSet { setNeedsDisplay() }
	}
		
	func drawProposedPath(along points: [[CGPoint]]) {
		self.points = points
	}
	
	func clearPath() {
		self.points = []
	}
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		
		UIColor.airMapDarkGray.setStroke()
		
		for pointArray in points {
			
			let cgPath = CGMutablePath()
			cgPath.addLines(between: pointArray)
			
			let uiPath = UIBezierPath(cgPath: cgPath)
			uiPath.setLineDash([6], count: 1, phase: 0)
			uiPath.lineWidth = 2.5
			uiPath.miterLimit = 2
			uiPath.lineJoinStyle = .round
			uiPath.stroke()
		}
	}
	
}
