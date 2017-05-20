//
//  ControlPointView.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/21/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit
import Mapbox

enum ControlPointType {
	case vertex
	case midPoint
}

class ControlPoint: MGLPointAnnotation {
	
	var type: ControlPointType
	
	init(type: ControlPointType = .vertex, coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()) {
		self.type = type
		super.init()
		self.coordinate = coordinate
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override var hashValue: Int {
		return coordinate.latitude.hashValue & coordinate.longitude.hashValue & type.hashValue
	}
}

public protocol ControlPointDelegate: class {
	func didStartDragging(_ controlPoint: ControlPointView)
	func didDrag(_ controlPoint: ControlPointView, to point: CGPoint)
	func didEndDragging(_ controlPoint: ControlPointView)
}

public class ControlPointView: MGLAnnotationView {
	
	weak var delegate: ControlPointDelegate?
	
	var controlPoint: ControlPoint? {
		return annotation as? ControlPoint
	}
	
	var type = ControlPointType.vertex {
		didSet { configureForType() }
	}
	
	init(type: ControlPointType) {
		super.init(reuseIdentifier: String(describing: type))
		
		self.type = type
		
		isDraggable = true
		scalesWithViewingDistance = false
		
		// Reduce annotation long press gesture delay
		gestureRecognizers?
			.flatMap { $0 as? UILongPressGestureRecognizer }
			.forEach { $0.minimumPressDuration = 0.08 }
		
		configureForType()
	}
	
	override init(frame: CGRect) {
		super.init(frame: CGRect(x: 0, y: 0, width: 35, height: 35))

		layer.backgroundColor = UIColor.clear.cgColor
		layer.borderWidth = 0
		layer.borderColor = UIColor.clear.cgColor
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		layer.cornerRadius = bounds.size.width / 2
	}
	
	fileprivate func configureForType() {
		
		let handle = CAShapeLayer()

		switch type {
			
		case .vertex:
			layer.zPosition = 0
			handle.path = UIBezierPath(ovalIn: frame.insetBy(dx: 8, dy: 8)).cgPath
			handle.fillColor = UIColor.white.cgColor
			handle.borderWidth = 2
			handle.strokeColor = UIColor.airMapDarkGray.cgColor
			handle.shadowColor = UIColor.airMapDarkGray.cgColor
			handle.shadowOpacity = 0.5
			handle.shadowOffset = CGSize(width: 3, height: 3)
			layer.addSublayer(handle)
			
		case .midPoint:
			layer.zPosition = -1
			handle.path = UIBezierPath(ovalIn: frame.insetBy(dx: 14, dy: 14)).cgPath
			handle.fillColor = UIColor.airMapDarkGray.cgColor
			layer.addSublayer(handle)
		}
	}
	
	public override func setDragState(_ dragState: MGLAnnotationViewDragState, animated: Bool) {
		super.setDragState(dragState, animated: animated)
		
		switch dragState {
		case .starting:
			delegate?.didStartDragging(self)
		case .dragging:
			delegate?.didDrag(self, to: center)
		case .ending, .canceling:
			delegate?.didEndDragging(self)
		case .none:
			break
		}
	}
	
}


