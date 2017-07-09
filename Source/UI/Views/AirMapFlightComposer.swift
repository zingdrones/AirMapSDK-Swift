//
//  AirMapFlightComposer.swift
//  AirMap
//
//  Created by Adolfo Martinelli on 5/18/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import UIKit
import Mapbox
import GLKit
import RxSwift
import RxCocoa
import RxSwiftExt
import SwiftTurf

public protocol AirMapFlightComposerDelegate: class {
	var mapView: AirMapMapView { get }
	func flightComposerDidUpdate(_ flightPlan: AirMapFlightPlan)
}

/// A helper class for creating point, path, or area flight plan on an AirMapMapView.
public class AirMapFlightComposer {

	/// The map view that will contain the draft flight plan
	
	/// A delegate to be notified of changes to the composed flight
	public weak var delegate: AirMapFlightComposerDelegate!
	
	// The views to update based on the flight composer's current state
	public var actionButton: UIButton!
	public var bufferSlider: UISlider!
	public var bufferTitleLabel: UILabel!
	public var bufferValueLabel: UILabel!
	public var toolTip: UILabel!
	
	var mapView: AirMapMapView {
		return delegate.mapView
	}
	
	var flightPlan: AirMapFlightPlan? {
		set {
			flightPlanVariable.value = newValue
		}
		get {
			return flightPlanVariable.value
		}
	}
	
	private var flightShapeSource = MGLShapeSource(identifier: "flight-shape")
	
	public init(delegate: AirMapFlightComposerDelegate) {
		self.delegate = delegate
	}
	
	public func setup() {
		
		setupDrawingOverlay()
		setupBindings()
		setOverlays(hidden: true, animated: false)		
	}
	
	@IBOutlet var flightTypeButtons: [AirMapFlightTypeButton]!
	
	let geoType = Variable(AirMapFlightGeometryType.point)
	let state = Variable(InteractionState.panning)
	let buffer = Variable(Feet(1000).meters)
	let flightPlanVariable = Variable(nil as AirMapFlightPlan?)
	
	fileprivate var drawingOverlayView: AirMapDrawingOverlayView {
		return mapView.drawingOverlay
	}
	fileprivate var editingOverlayView: AirMapEditingOverlayView {
		return mapView.editingOverlay
	}
	
	fileprivate let mapViewDelegate = AirMapMapboxMapViewDelegate()
	
	fileprivate let controlPoints = Variable([ControlPoint]())
	
	fileprivate let disposeBag = DisposeBag()
	
	/// Begins the flight composing process
	///
	/// - Parameter type: A flight type to begin with. Defaults to point and radius.
	public func startComposingFlight(type: AirMapFlightGeometryType = .point, buffer: Meters) {
		
		if flightPlan == nil {
			flightPlan = AirMapFlightPlan(coordinate: mapView.centerCoordinate)
		}
		
		flightPlan?.takeoffCoordinate = mapView.centerCoordinate
		
		// Order is important here as we first want to set the type, then configure buffer
		self.geoType.value = type
		self.buffer.value = buffer
		
		setOverlays(hidden: false)
		delegate.flightComposerDidUpdate(flightPlan!)
	}
	
	/// Cancels the composition of a flight plan
	public func cancelComposingFlight() {
		state.value = .finished
		setOverlays(hidden: true)
		mapView.draftFlightSource?.shape = nil
	}
	
	/// Completes flight composing and returns a flight plan if it contains valid
	/// geometry. Call hasValidFlightGeometry() to verify flight before finishing
	///
	/// - Returns: A flight plan if a valid one is available
	public func finishComposingFlight() -> AirMapFlightPlan? {
		state.value = .finished
		setOverlays(hidden: true)
		return flightPlan
	}
	
	public func annotationView(for controlPoint: ControlPoint) -> ControlPointView {
		
		if let controlPointView = mapView.dequeueReusableAnnotationView(withIdentifier: String(describing: controlPoint.type)) as? ControlPointView {
			return controlPointView
		} else {
			let controlPointView = ControlPointView(type: controlPoint.type)
			controlPointView.delegate = self
			return controlPointView
		}
	}
	
	public func annotationView(for invalidIntersection: InvalidIntersection) -> InvalidIntersectionView {
		
		if let invalidIntersectionView = mapView.dequeueReusableAnnotationView(withIdentifier: String(describing: InvalidIntersectionView.self)) as? InvalidIntersectionView {
			return invalidIntersectionView
		} else {
			return InvalidIntersectionView()
		}
	}
	
	fileprivate func setOverlays(hidden: Bool, animated: Bool = true) {
		UIView.animate(withDuration: animated ? 0.3 : 0, delay: hidden ? 0 : 0.3, options: [.beginFromCurrentState], animations: {
			let alpha: CGFloat = hidden ? 0 : 1
			if self.geoType.value != .point || hidden {
				self.toolTip.superview?.superview?.alpha = alpha
			}
			self.actionButton.alpha = alpha
		}, completion: nil)
	}
}

// MARK: - Internal

enum InteractionState {
	case panning
	case drawing
	case editing(ControlPoint)
	case finished
}

extension InteractionState: Equatable {
	
	static func ==(lhs: InteractionState, rhs: InteractionState) -> Bool {
		switch (lhs, rhs) {
		case (.panning, .panning), (.drawing, .drawing), (.finished, .finished):
			return true
		case (.editing(let point1), .editing(let point2)):
			return point1 === point2
		default:
			return false
		}
	}
}

public class FlightPlanArea: MGLPolygon {
	
	public var statusColor: AirMapStatus.StatusColor = .gray
	
}

public class InvalidIntersection: NSObject, MGLAnnotation {
	
	public var coordinate: CLLocationCoordinate2D
	
	init(coordinate: CLLocationCoordinate2D) {
		self.coordinate = coordinate
	}
}

public class InvalidIntersectionView: MGLAnnotationView {
	
	init() {
		super.init(reuseIdentifier: String(describing: InvalidIntersection.self))
		
		isUserInteractionEnabled = false
		scalesWithViewingDistance = false
	}
	
	override init(frame: CGRect) {
		super.init(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
		
		layer.backgroundColor = UIColor.clear.cgColor
		layer.zPosition = -100
		layer.borderWidth = 2
		layer.opacity = 0.5
		layer.borderColor = UIColor.airMapRed.cgColor
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		layer.cornerRadius = bounds.size.width / 2
	}
}

extension AirMapFlightComposer: AnalyticsTrackable {
	
	// MARK: Properties
	
	var screenName: String {
		switch geoType.value {
		case .point:
			return "Create Flight - Point"
		case .path:
			return "Create Flight - Path"
		case .polygon:
			return "Create Flight - Polygon"
		}
	}
	
	// MARK: Setup
	
	fileprivate func setupBindings() {
		
		typealias FC = AirMapFlightComposer
		
		let latestType = geoType.asObservable().distinctUntilChanged().share()
		let latestState = state.asObservable().distinctUntilChanged().share()
		let latestBuffer = buffer.asObservable().share()
		let latestPoints = controlPoints.asObservable().share()
		
		// Configure for the flight geometry type
		latestType.subscribeNext(weak: self, FC.configureForType)
			.disposed(by: disposeBag)
		
		// Configure for the flight geometry type and interaction state
		Observable.combineLatest(latestType, latestState, latestPoints) { $0 }
//			.debounce(0.1, scheduler: MainScheduler.instance)
			.subscribeNext(weak: self, FC.configureForState)
			.disposed(by: disposeBag)
		
		// Add the control points to the map
		latestPoints
			.subscribeNext(weak: self, FC.drawControlPoints)
			.disposed(by: disposeBag)
		
		// Convert the slider buffer value to a display string & value tuple
		let sliderBuffer = bufferSlider.rx.value
			.distinctUntilChanged()
			.map(unowned(self, FC.sliderValueToBuffer))
			.share()
		
		// Display the buffer string value
		sliderBuffer.map { $0.displayString }
			.bind(to: bufferValueLabel.rx.text)
			.disposed(by: disposeBag)
		
		// Draw the new proposed radius as the user interacts with the slider
		sliderBuffer.map { $0.buffer }
			.subscribeNext(weak: self, FC.drawNewProposedRadius)
			.disposed(by: disposeBag)
		
		// After a debounce, commit the slider's buffer value to the flight plan's buffer
		sliderBuffer.map { $0.buffer }
			.debounce(0.5, scheduler: MainScheduler.instance)
			.bind(to: buffer)
			.disposed(by: disposeBag)
		
		// Get the coordinates for all the control point vertices
		let latestCoordinates = latestPoints
			.map { $0.filter { $0.type == ControlPointType.vertex }.map { $0.coordinate } }
			.share()
		
		// Validate that the coordinates for the geo type are valid
		let validation = Observable
			.combineLatest(latestType, latestCoordinates) { $0 }
			.map(unowned(self, FC.geometryValidation))
			.share()
		
		// Update the flight plan object with the latest properties
		let updatedFlightPlan = Observable
			.combineLatest(flightPlanVariable.asObservable().unwrap(), latestType, latestCoordinates, latestBuffer) { $0 }
			.map(unowned(self, FC.updatedFlightPlan))
			.share()
		
		// Build the annotations that will be added to the map representing the flight plan and any invalid kinks, etc.
		let flightAnnotations = Observable
			.combineLatest(updatedFlightPlan, validation) { $0 }
			.map(unowned(self, FC.flightAnnotations))
			.share()
		
		// Add the latest flight plan annotations to the map
		flightAnnotations
			.subscribeNext(weak: self, FC.updateMap)
			.disposed(by: disposeBag)
		
		// Validate the flight plan and notify the delegate
		Observable
			.combineLatest(updatedFlightPlan, validation) { $0 }
			.map(unowned(self, FC.validatedFlightPlan))
			.do(onNext: { [weak self] (flightPlan) in
				self?.delegate?.flightComposerDidUpdate(flightPlan)
			})
			.subscribe()
			.disposed(by: disposeBag)
		
		// Update the map source that displays a draft flight plan
		Observable.combineLatest(updatedFlightPlan, latestBuffer) { ($0.0.geometry, $0.1) }
			.subscribeNext(weak: mapView, AirMapMapView.updateDraftFlightPlan)
			.disposed(by: disposeBag)
		
		// Center the flight plan geometry within the view after adjusting the buffer
		latestBuffer.asObservable()
			.withLatestFrom(Observable.combineLatest(flightAnnotations, latestType) { $0 })
			.subscribeNext(weak: self, FC.centerFlightPlan)
			.disposed(by: disposeBag)
		
		// Analytics
		sliderBuffer.map { $0.buffer }
			.debounce(2, scheduler: MainScheduler.instance)
			.subscribe(onNext: { [unowned self] meters in
				self.trackEvent(.slide, label: "Buffer", value: NSNumber(value: meters))
			})
			.disposed(by: disposeBag)
	}
	
	fileprivate func setupDrawingOverlay() {
		drawingOverlayView.delegate = self
	}
		
	// MARK: Configure
	
	func configureForType(_ type: AirMapFlightGeometryType) {
		
		let radiusSliderAlpha: CGFloat
		
		toolTip.superview?.superview?.alpha = 1.0
		
		switch type {
			
		case .point:
			actionButton.isHidden = true
			bufferTitleLabel.text = LocalizedStrings.FlightDrawing.radius
			toolTip.superview!.superview!.alpha = 0.0
			controlPoints.value = [
				ControlPoint(type: .vertex, coordinate: mapView.centerCoordinate)
			]
			radiusSliderAlpha = 1
			state.value = .panning
			
		case .path:
			actionButton.isHidden = false
			bufferTitleLabel.text = LocalizedStrings.FlightDrawing.width
			controlPoints.value = []
			radiusSliderAlpha = 1
			drawingOverlayView.discardsDuplicateClosingPoint = false
			state.value = .drawing
			
		case .polygon:
			actionButton.isHidden = false
			controlPoints.value = []
			radiusSliderAlpha = 0
			drawingOverlayView.discardsDuplicateClosingPoint = true
			state.value = .drawing
		}
		
		let animations: () -> Void = {
			self.bufferSlider.superview?.alpha = radiusSliderAlpha
		}
		
		UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState], animations: animations, completion: nil)
	}
	
	func configureForState(type: AirMapFlightGeometryType, state: InteractionState, controlPoints: [ControlPoint]) {
		
		let bundle = AirMapBundle.ui
		let localized = LocalizedStrings.FlightDrawing.self
		
		let drawIcon = UIImage(named: "draw_icon", in: bundle, compatibleWith: nil)!
		let drawIconSelected = UIImage(named: "draw_icon_selected", in: bundle, compatibleWith: nil)!
		
		let trashIcon = UIImage(named: "trash_icon", in: bundle, compatibleWith: nil)
		let trashIconSelected = UIImage(named: "trash_icon_selected", in: bundle, compatibleWith: nil)
		let trashIconHighlighted = UIImage(named: "trash_icon_highlighted", in: bundle, compatibleWith: nil)
		let toolTipBgColor = UIColor.airMapDarkGray.withAlphaComponent(0.25)
		toolTip.superview?.backgroundColor = toolTipBgColor
		
		switch state {
			
		case .panning:
			
			// No existing shape
			if controlPoints.count == 0 {
				
				switch type {
				case .point:    toolTip.text = localized.toolTipCtaTapToDrawPoint
				case .path:     toolTip.text = localized.toolTipCtaTapToDrawPath
				case .polygon:  toolTip.text = localized.toolTipCtaTapToDrawArea
				}
				
				actionButton.setImage(drawIcon, for: UIControlState())
				actionButton.setImage(drawIconSelected, for: .highlighted)
				actionButton.setImage(drawIconSelected, for: .selected)
				actionButton.addTarget(self, action: #selector(toggleDrawing), for: .touchUpInside)
				
			} else { // Has existing shape
				
				let coordinates = controlPoints
					.filter { $0.type == .vertex }
					.map { $0.coordinate }
				
				let validation = geometryValidation(type, coordinates: coordinates)
				
				if (validation.kinks?.features.count ?? 0) > 0 {
					toolTip.text = localized.tooltipErrorSelfIntersectingGeometry
					toolTip.superview?.backgroundColor = UIColor.airMapRed.withAlphaComponent(0.50)
				} else {
					toolTip.text = localized.toolTipCtaDragPointToModifyGeometry
				}
				
				actionButton.setImage(trashIcon, for: UIControlState())
				actionButton.setImage(trashIconHighlighted, for: .highlighted)
				actionButton.setImage(trashIconSelected, for: .selected)
				actionButton.addTarget(self, action: #selector(deleteShape(_:)), for: .touchUpInside)
			}
			actionButton.isSelected = false
			actionButton.isHighlighted = false
			
			drawingOverlayView.isHidden = true
			editingOverlayView.clearPath()
			
			mapView.setControlPoints(hidden: false)
			
		case .drawing:
			
			switch type {
			case .point:
				drawingOverlayView.isHidden = true
			case .path:
				mapView.bringSubview(toFront: drawingOverlayView)
				drawingOverlayView.isHidden = false
				toolTip.text = localized.toolTipCtaDrawFreehandPath
				drawingOverlayView.tolerance = 8
			case .polygon:
				mapView.bringSubview(toFront: drawingOverlayView)
				drawingOverlayView.isHidden = false
				toolTip.text = localized.toolTipCtaDrawFreehandArea
				drawingOverlayView.tolerance = 11
			}
			
			actionButton.setImage(drawIcon, for: UIControlState())
			actionButton.setImage(drawIconSelected, for: .highlighted)
			actionButton.setImage(drawIconSelected, for: .selected)
			actionButton.isSelected = true
			actionButton.isHighlighted = false
			actionButton.addTarget(self, action: #selector(toggleDrawing), for: .touchUpInside)
			
			editingOverlayView.clearPath()
			
		case .editing(let controlPoint):
			
			editingOverlayView.isHidden = false
			drawingOverlayView.isHidden = true
			
			if canDelete(controlPoint) {
				toolTip.text = localized.toolTipCtaDragToTrashToDelete
			}
			actionButton.setImage(trashIcon, for: UIControlState())
			actionButton.setImage(trashIconHighlighted, for: .highlighted)
			actionButton.setImage(trashIconSelected, for: .selected)
			actionButton.addTarget(self, action: #selector(deleteShape), for: .touchUpInside)
			
			if type != .point {
				mapView.setControlPoints(hidden: true)
			}
			
		case .finished:
			drawingOverlayView.isHidden = true
			editingOverlayView.isHidden = true
			editingOverlayView.clearPath()
		}
		
		mapView.hideObscuredMidPointControls()
	}
	
	fileprivate func sliderValueToBuffer(sliderValue: Float) -> (buffer: Meters, displayString: String) {
		
		let ramp = Config.Maps.bufferSliderLinearity
		let sliderValue = pow(Double(sliderValue), ramp)
		
		let usesMetric = AirMap.configuration.distanceUnits == .metric
		let distancePerStep: Double
		
		let formatter = UIConstants.flightDistanceFormatter
		let bufferValue: (buffer: Meters, displayString: String)
		
		if usesMetric {
			
			let minRadius = Meters(5.0)
			let maxRadius = Meters(1000.0)
			var meters = (sliderValue * (maxRadius - minRadius)) + minRadius
			switch meters {
			case 50..<200:
				distancePerStep = 10
			case 200..<750:
				distancePerStep = 50
			case 750..<1000:
				distancePerStep = 100
			default:
				distancePerStep = 5
			}
			meters = ceil(meters / distancePerStep) * distancePerStep
			
			bufferValue = (meters, formatter.string(fromValue: meters, unit: .meter))
			
		} else {
			
			let minRadius = Feet(25).meters
			let maxRadius = Feet(3000).meters
			let meters = (sliderValue * (maxRadius - minRadius)) + minRadius
			var feet = meters.feet
			
			switch feet {
			case 200..<500:
				distancePerStep = 50
			case 500..<1000:
				distancePerStep = 100
			case 1000..<2000:
				distancePerStep = 250
			case 2000..<3000:
				distancePerStep = 500
			default:
				distancePerStep = 25
			}
			feet = ceil(feet / distancePerStep) * distancePerStep
			
			bufferValue = (feet.meters, formatter.string(fromValue: feet, unit: .foot))
		}
		
		return bufferValue
	}
	
	// MARK: Actions
	
	@IBAction func selectFlightMode(_ button: AirMapFlightTypeButton) {
		
		trackView()
		
		flightTypeButtons.forEach { $0.isSelected = false }
		button.isSelected = true
		
		let index = flightTypeButtons.index(of: button)!
		let geoTypes: [AirMapFlightGeometryType] = [.point, .path, .polygon]
		let geoType = geoTypes[index]
		
		switch geoType {
		case .point:
			bufferSlider.value = 0.5667
			trackEvent(.tap, label: "Point")
		case .path:
			bufferSlider.value = 20/1000
			trackEvent(.tap, label: "Path")
		case .polygon:
			trackEvent(.tap, label: "Polygon")
		}
		
		bufferSlider.sendActions(for: .valueChanged)
		self.geoType.value = geoType
	}
	
	@objc fileprivate func toggleDrawing() {
		
		switch state.value {
		case .drawing:
			state.value = .panning
		default:
			state.value = .drawing
		}
	}
	
	@objc func deleteShape(_ sender: AnyObject?) {
		
		geoType.value = geoType.value
		
		if sender is UIButton {
			trackEvent(.tap, label: "Trash Icon")
		}
	}
	
	// MARK: Getters
	
	fileprivate func midPointControlPoints(from controlPoints: [ControlPoint]) -> [ControlPoint] {
		
		let midPointCoordinates: [CLLocationCoordinate2D] = controlPoints.enumerated().flatMap { index, controlPoint in
			
			let lCoord = controlPoint.coordinate
			let rCoord: CLLocationCoordinate2D
			if index == controlPoints.endIndex-1 {
				rCoord = controlPoints[controlPoints.startIndex].coordinate
			} else {
				rCoord = controlPoints[index+1].coordinate
			}
			
			let lPoint = mapView.convert(lCoord, toPointTo: mapView)
			let rPoint = mapView.convert(rCoord, toPointTo: mapView)
			
			let midPoint = CGPoint(x: (lPoint.x + rPoint.x)/2, y: (lPoint.y + rPoint.y)/2)
			
			return mapView.convert(midPoint, toCoordinateFrom: mapView)
		}
		
		var midPointControlPoints: [ControlPoint] = midPointCoordinates.map {
			ControlPoint(type: .midPoint, coordinate: $0)
		}
		
		if geoType.value == .path {
			midPointControlPoints.removeLast()
		}
		
		return midPointControlPoints
	}
	
	fileprivate func neighbors(of controlPoint: ControlPoint, distance: Int) -> (prev: ControlPoint?, next: ControlPoint?) {
		
		let index = controlPoints.value.index(of: controlPoint)! + controlPoints.value.endIndex // add endIndex to enable wrapping
		
		let prevIndex = (index-distance) % controlPoints.value.endIndex
		let nextIndex = (index+distance) % controlPoints.value.endIndex
		
		let prevPoint = controlPoints.value[prevIndex]
		let nextPoint = controlPoints.value[nextIndex]
		
		if geoType.value == .path {
			switch controlPoint {
			case controlPoints.value.first!:
				return (nil, nextPoint)
			case controlPoints.value.last!:
				return (prevPoint, nil)
			default:
				return (prevPoint, nextPoint)
			}
		} else {
			return (prevPoint, nextPoint)
		}
	}
	
	fileprivate func canDelete(_ controlPoint: ControlPoint) -> Bool {
		
		let isVertex = controlPoint.type == .vertex
		let vertexCount = controlPoints.value.filter{ $0.type == .vertex }.count
		
		switch geoType.value {
		case .point:
			return false
		case .path:
			return isVertex && vertexCount > 2
		case .polygon:
			return isVertex && vertexCount > 3
		}
	}
	
	fileprivate func geometryValidation(_ geoType: AirMapFlightGeometryType, coordinates: [CLLocationCoordinate2D]) -> (valid: Bool, kinks: FeatureCollection?) {
		
		switch geoType {
		case .point:
			return (coordinates.count == 1, nil)
		case .polygon:
			guard coordinates.count >= 3 else { return (false, nil) }
			let polygon = Polygon(geometry: [coordinates + [coordinates.first!]])
			let kinks = SwiftTurf.kinks(polygon)!
			return (coordinates.count >= 3 && kinks.features.count == 0, kinks)
		case .path:
			return (coordinates.count >= 2, nil)
		}
	}
	
	// MARK: Drawing
	
	fileprivate func drawControlPoints(_ points: [ControlPoint]) {
		
		let existingPoints = mapView.annotations?.flatMap({ $0 as? ControlPoint }) ?? []
		mapView.removeAnnotations(existingPoints)
		mapView.addAnnotations(points)
	}
	
	fileprivate func drawNewProposedRadius(_ radius: Meters = 0) {
		
		guard controlPoints.value.count > 0 else { return }
		
		editingOverlayView.isHidden = false
		
		switch self.geoType.value {
			
		case .point:
			let centerPoint = controlPoints.value.first!
			let point = Point(geometry: centerPoint.coordinate)
			let bufferedPoint = SwiftTurf.buffer(point, distance: radius, units: .Meters)
			let proposedCoords = bufferedPoint?.geometry.first ?? []
			let proposedPoints = proposedCoords.map { mapView.convert($0, toPointTo: mapView) }
//			state.value = .editing(centerPoint)
			editingOverlayView.drawProposedPath(along: [proposedPoints])
			
		case .path:
			let pathCoordinates = controlPoints.value.map { $0.coordinate }
			let lineString = LineString(geometry: pathCoordinates)
			guard let bufferedPath = SwiftTurf.buffer(lineString, distance: radius / 2) else { return }
			let proposedPoints = bufferedPath.geometry.map {
				$0.map { mapView.convert($0, toPointTo: mapView)
				}
			}
			editingOverlayView.drawProposedPath(along: proposedPoints)
			
		case .polygon:
			// Polygons don't support a buffer -- yet
			break
		}
	}
	
	fileprivate func updatedFlightPlan(flightPlan: AirMapFlightPlan, geoType: AirMapFlightGeometryType, coordinates: [CLLocationCoordinate2D], buffer: Meters) -> AirMapFlightPlan {
		
		switch geoType {
			
		case .point:
			let coordinate = coordinates.first ?? mapView.centerCoordinate
			let point = AirMapPoint(coordinate: coordinate)
			flightPlan.geometry = point
			flightPlan.takeoffCoordinate = coordinate
			flightPlan.buffer = buffer
			
		case .path:
			if coordinates.count >= 2 {
				flightPlan.geometry = AirMapPath(coordinates: coordinates)
			} else {
				flightPlan.geometry = nil
			}
			flightPlan.takeoffCoordinate = coordinates.first ?? mapView.centerCoordinate
			flightPlan.buffer = buffer / 2
			
		case .polygon:
			if coordinates.count >= 3 {
				let closedPoints = coordinates + [coordinates.first!]
				flightPlan.geometry = AirMapPolygon(coordinates: [closedPoints])
				flightPlan.takeoffCoordinate = coordinates.first!
			} else {
				flightPlan.geometry = nil
				flightPlan.takeoffCoordinate = mapView.centerCoordinate
			}
			flightPlan.buffer = buffer
		}
		
		return flightPlan
	}
	
	fileprivate func validatedFlightPlan(flightPlan: AirMapFlightPlan, validation: (valid: Bool, kinks: FeatureCollection?)) -> AirMapFlightPlan {
		
		if validation.valid == false {
			flightPlan.geometry = nil
		}
		return flightPlan
	}
	
	fileprivate func flightAnnotations(flightPlan: AirMapFlightPlan, validation: (valid: Bool, kinks: FeatureCollection?)) -> [MGLAnnotation] {
		
		guard let geometry = flightPlan.geometry else { return [] }
		
		switch geometry.type {
		case .point, .path:
			return []
		case .polygon:
			return invalidIntersections(from: validation.kinks)
		}
	}
	
	fileprivate func invalidIntersections(from kinks: FeatureCollection?) -> [InvalidIntersection] {
		
		return kinks?.features
			.flatMap({$0 as? Point})
			.map({ $0.geometry })
			.map(InvalidIntersection.init) ?? []
	}
	
	fileprivate func updateMap(annotations: [MGLAnnotation]) {
		
		editingOverlayView.isHidden = true
		
		mapView.annotations?
			.filter { ($0 is MGLPolygon || $0 is MGLPolyline || $0 is InvalidIntersection) }
			.forEach { mapView.removeAnnotation($0) }
		
		mapView.addAnnotations(annotations)
	}
	
	fileprivate func centerFlightPlan(annotations: [MGLAnnotation], type: AirMapFlightGeometryType) {
		
		let insets: UIEdgeInsets
		
		switch type {
		case .path:
			insets = UIEdgeInsetsMake(90, 45, 150, 60)
		case .polygon:
			insets = UIEdgeInsetsMake(90, 45, 150, 60)
		case .point:
			insets = UIEdgeInsetsMake(60, 45, 150, 45)
		}
		
		mapView.showAnnotations(annotations, edgePadding: insets, animated: true)
	}
	
	fileprivate func position(_ midControlPoint: ControlPoint, between controlpoints: (prev: ControlPoint?, next: ControlPoint?)) {
		
		guard let prev = controlpoints.prev, let next = controlpoints.next else { return }
		
		let prevCoord = prev.coordinate
		let nextCoord = next.coordinate
		
		let prevPoint = mapView.convert(prevCoord, toPointTo: mapView)
		let nextPoint = mapView.convert(nextCoord, toPointTo: mapView)
		
		let midPoint = CGPoint(x: (prevPoint.x + nextPoint.x)/2, y: (prevPoint.y + nextPoint.y)/2)
		
		midControlPoint.coordinate = mapView.convert(midPoint, toCoordinateFrom: mapView)
	}
}

// MARK: - DrawingOverlayDelegate

extension AirMapFlightComposer: DrawingOverlayDelegate {
	
	func overlayDidDraw(geometry: [CGPoint]) {
		
		let coordinates = geometry.map { point in
			mapView.convert(point, toCoordinateFrom: drawingOverlayView)
		}
		
		// Validate drawn input
		// Discard shapes not meeting minimum/maximum number of points
		switch geoType.value {
		case .path:
			guard coordinates.count > 1 && coordinates.count <= 25 else { return }
			trackEvent(.draw, label: "Draw Path", value: coordinates.count as NSNumber)
			// Ensure points first two points are at least 25m apart. This catches paths created when double tapping the map.
			
			let (coord0, coord1) = (coordinates[0], coordinates[1])
			
			let loc0 = CLLocation(latitude: coord0.latitude, longitude: coord0.longitude)
			let loc1 = CLLocation(latitude: coord1.latitude, longitude: coord1.longitude)
			
			guard loc0.distance(from: loc1) > 25 else {
				return
			}
		case .polygon:
			guard coordinates.count > 2 else { return }
			trackEvent(.draw, label: "Draw Polygon", value: coordinates.count as NSNumber)
			// Discard polygons with too many self-intersections
			let polygon = Polygon(geometry: [coordinates])
			guard (SwiftTurf.kinks(polygon)?.features.count ?? 0) <= 5 else { return }
		case .point:
			return
		}
		
		let vertexControlPoints: [ControlPoint] = coordinates.map {
			ControlPoint(type: .vertex, coordinate: $0)
		}
		let midPointControlPoints = self.midPointControlPoints(from: vertexControlPoints)
		var controlPoints = zip(vertexControlPoints, midPointControlPoints).flatMap { [$0.0, $0.1] }
		
		if geoType.value == .path {
			controlPoints.append(vertexControlPoints.last!)
		}
		
		self.controlPoints.value = controlPoints
		state.value = .panning
	}
}

// MARK: - ControlPointDelegate

extension AirMapFlightComposer: ControlPointDelegate {
	
	public func didStartDragging(_ controlPoint: ControlPointView) {
		
		mapView.setControlPoints(hidden: true)
	}
	
	public func didDrag(_ controlPointView: ControlPointView, to point: CGPoint) {
		
		guard let controlPoint = controlPointView.controlPoint else { return }
		let controlPointCoordinate = mapView.convert(point, toCoordinateFrom: mapView)
		
		state.value = .editing(controlPoint)
		
		// shrink the control point so that the drag can break out sooner
		UIView.performWithoutAnimation {
			controlPointView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
		}
		
		switch geoType.value {
			
		case .point:
			
			trackEvent(.drag, label: "Drag Point")
			
			let point = Point(geometry: controlPointCoordinate)
			let bufferedPoint = SwiftTurf.buffer(point, distance: buffer.value, units: .Meters)
			let coordinates = bufferedPoint?.geometry.first ?? []
			let points = coordinates.map { mapView.convert($0, toPointTo: mapView) }
			editingOverlayView.drawProposedPath(along: [points])
			
		case .polygon, .path:
			
			let distance = controlPoint.type == .midPoint ? 1 : 2
			let neighbors = self.neighbors(of: controlPoint, distance: distance)
			let points = [neighbors.prev, ControlPoint(coordinate: controlPointCoordinate), neighbors.next]
				.flatMap { $0 }
				.map { mapView.convert($0.coordinate, toPointTo: mapView) }
			
			editingOverlayView.drawProposedPath(along: [points])
			
			if canDelete(controlPoint) {
				actionButton.isHighlighted = true
				let actionButtonRect = mapView.convert(actionButton.frame, to: mapView)
				if actionButtonRect.contains(point) {
					actionButton.isHighlighted = false
					actionButton.isSelected = true
				}
			}
		}
	}
	
	public func didEndDragging(_ controlPointView: ControlPointView) {
		
		controlPointView.transform = CGAffineTransform.identity
		
		guard let controlPoint = controlPointView.controlPoint else { return }
		
		switch geoType.value {
			
		case .path, .polygon:
			
			if geoType.value == .path {
				trackEvent(.drag, label: "Drag Path Point")
			}
			
			if geoType.value == .polygon {
				trackEvent(.drag, label: "Drag Polygon Point")
			}
			
			let actionButtonRect = mapView.convert(actionButton.frame, to: mapView)
			
			let hitPoint = mapView.convert(controlPoint.coordinate, toPointTo: mapView)
			let shouldDeletePoint = canDelete(controlPoint) && actionButtonRect.contains(hitPoint)
			
			switch controlPoint.type {
				
			case .vertex:
				
				let midPoints = neighbors(of: controlPoint, distance: 1)
				if shouldDeletePoint {
					let controlPointsToDelete: [ControlPoint]
					if controlPoint == controlPoints.value.first {
						controlPointsToDelete = [controlPoint, midPoints.next].flatMap { $0 }
					} else {
						controlPointsToDelete = [controlPoint, midPoints.prev].flatMap { $0 }
					}
					controlPoints.value.removeObjectsInArray(controlPointsToDelete)
					mapView.annotations?
						.flatMap { $0 as? ControlPoint }
						.filter { $0.type == .midPoint }
						.forEach { midPoint in
							let vertices = neighbors(of: midPoint, distance: 1)
							position(midPoint, between: vertices)
					}
					trackEvent(.drop, label: "Drop Point Trash Icon")
				} else {
					for midPoint in [midPoints.prev, midPoints.next].flatMap({$0}) {
						let vertices = neighbors(of: midPoint, distance: 1)
						position(midPoint, between: vertices)
					}
				}
				
			case .midPoint:
				
				trackEvent(.drag, label: "Drag New Point") // Add New Point
				
				controlPoint.type = .vertex
				
				mapView.removeAnnotation(controlPoint)
				
				let left = ControlPoint(type: .midPoint)
				let right = ControlPoint(type: .midPoint)
				
				let index = controlPoints.value.index(of: controlPoint)!
				controlPoints.value.insert(left, at: index)
				controlPoints.value.insert(right, at: index+2)
				
				position(left, between: neighbors(of: left, distance: 1))
				position(right, between: neighbors(of: right, distance: 1))
			}
			
		case .point:
			trackEvent(.drag, label: "Drag Point")
		}
		
		controlPoints.value = controlPoints.value
		state.value = .panning
	}
	
}
