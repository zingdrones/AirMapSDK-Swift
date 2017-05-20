//
//  AirMapCreateFlightTypeViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/12/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit
import Mapbox
import GLKit
import RxSwift
import RxCocoa
import RxSwiftExt
import SwiftTurf


class Buffer: MGLPolygon {}

class InvalidIntersection: NSObject, MGLAnnotation {
	
	var coordinate: CLLocationCoordinate2D
	
	init(coordinate: CLLocationCoordinate2D) {
		self.coordinate = coordinate
	}
}

class InvalidIntersectionView: MGLAnnotationView {
	
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
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		layer.cornerRadius = bounds.size.width / 2
	}
}

class AirMapCreateFlightTypeViewController: UIViewController, AnalyticsTrackable {
	
	// MARK: Properties
	
	var screenName: String {
		switch selectedGeoType.value {
		case .point:
			return "Create Flight - Point"
		case .path:
			return "Create Flight - Path"
		case .polygon:
			return "Create Flight - Polygon"
		}
	}

	@IBOutlet weak var mapView: AirMapMapView!
	@IBOutlet weak var actionButton: UIButton!
	@IBOutlet weak var bufferSlider: UISlider!
	@IBOutlet weak var bufferTitleLabel: UILabel!
	@IBOutlet weak var bufferValueLabel: UILabel!
	@IBOutlet weak var toolTip: UILabel!
	@IBOutlet weak var bottomToolTip: UILabel!
	
	@IBOutlet var flightTypeButtons: [AirMapFlightTypeButton]!
	
	fileprivate let drawingOverlayView = AirMapDrawingOverlayView()
	fileprivate let editingOverlayView = AirMapEditingOverlayView()
	fileprivate let mapViewDelegate = AirMapMapboxMapViewDelegate()

	fileprivate let geoTypes: [AirMapFlight.FlightGeometryType] = [.point, .path, .polygon]
	fileprivate let selectedGeoType = Variable(AirMapFlight.FlightGeometryType.point)
	fileprivate let controlPoints = Variable([ControlPoint]())
	fileprivate let state = Variable(InteractionState.panning)
	fileprivate let buffer = Variable(Feet(1000).meters)
	
	fileprivate let controlPointsHidden = Variable(false)
		
	fileprivate var flight: AirMapFlight!
	
	fileprivate let disposeBag = DisposeBag()
		
	// MARK: View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupMap()
		setupDrawingOverlay()
		setupEditingOverlay()
		setupBindings()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		trackView()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		drawingOverlayView.frame = mapView.frame
		editingOverlayView.frame = mapView.bounds
		
		// Insert the editing view below the annotations view
		if let mapGLKView = mapView.subviews.filter({ $0 is GLKView }).first {
			mapGLKView.insertSubview(editingOverlayView, at: 0)
		}
	}
	
	// MARK: Setup

	fileprivate func setupBindings() {
		
		typealias $ = AirMapCreateFlightTypeViewController
				
		let geoType = selectedGeoType.asDriver().distinctUntilChanged()
		let coordinates = controlPoints.asDriver()
			.map { $0.filter { $0.type == ControlPointType.vertex }.map { $0.coordinate } }

		geoType
			.drive(onNext: unowned(self, $.configureForType))
			.disposed(by: disposeBag)
		
        Driver.combineLatest(geoType, buffer.asDriver()) { $0 }
            .mapToVoid()
			.throttle(0.25)
			.drive(onNext: unowned(self, $.centerFlightPlan))
			.disposed(by: disposeBag)

		state.asDriver()
			.throttle(0.01)
			.drive(onNext: unowned(self, $.configureForState))
			.disposed(by: disposeBag)
		
		controlPoints.asDriver()
			.drive(onNext: unowned(self, $.drawControlPoints))
			.disposed(by: disposeBag)
	
		let snappedBuffer = bufferSlider.rx.value.asDriver()
            .distinctUntilChanged()
            .map(unowned(self, $.sliderValueToBuffer))

		snappedBuffer.map { $0.displayString }
			.drive(bufferValueLabel.rx.text)
			.disposed(by: disposeBag)

		snappedBuffer.map { $0.buffer }
			.drive(onNext: unowned(self, $.drawNewProposedRadius))
			.disposed(by: disposeBag)

		snappedBuffer.map { $0.buffer }
			.throttle(0.25)
			.drive(buffer)
			.disposed(by: disposeBag)
		
		snappedBuffer.map { $0.buffer }
			.throttle(1)
			.distinctUntilChanged()
			.drive(onNext: { [unowned self] meters in
				self.trackEvent(.slide, label: "Buffer", value: NSNumber(value: meters))
			})
			.disposed(by: disposeBag)

		let validatedInput = Driver
			.combineLatest(geoType, coordinates, buffer.asDriver()) { [unowned self] geoType, coordinates, buffer in
				(geoType, coordinates, buffer, self.geometryValidation(geoType, coordinates: coordinates))
			}

		validatedInput
			.drive(onNext: unowned(self, $.drawFlightArea))
			.disposed(by: disposeBag)

		controlPointsHidden.asDriver()
			.drive(onNext: mapView.hideControlPoints)
			.disposed(by: disposeBag)
	}
	
	fileprivate func setupMap() {
		
		mapView.delegate = mapViewDelegate
		mapViewDelegate.controlPointDelegate = self
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleAnnotations))
		mapView.addGestureRecognizer(tapGesture)
		
		// Prevent calling of single tap for multi-tap gestures (i.e. double taps)
		mapView.gestureRecognizers?
			.flatMap { $0 as? UITapGestureRecognizer }
			.filter { $0.numberOfTapsRequired > 1 }
			.forEach { tapGesture.require(toFail: $0) }
 	}
	
	@objc fileprivate func toggleAnnotations() {
		if selectedGeoType.value != .point {
			controlPointsHidden.value = !controlPointsHidden.value
		}
	}
	
	fileprivate func setupDrawingOverlay() {
		drawingOverlayView.delegate = self
		drawingOverlayView.isMultipleTouchEnabled = false
		drawingOverlayView.backgroundColor = UIColor.airMapDarkGray.withAlphaComponent(0.333)
		view.insertSubview(drawingOverlayView, belowSubview: actionButton)
	}
	
	fileprivate func setupEditingOverlay() {
		editingOverlayView.backgroundColor = .clear
		editingOverlayView.isUserInteractionEnabled = false
		// Editing overlay is inserted into the view hierarchy in viewDidLayoutSubviews
	}
	
	// MARK: Configure

	func configureForType(_ type: AirMapFlight.FlightGeometryType) {
		if let annotations = mapView.annotations {
			mapView.removeAnnotations(annotations)
		}
		
		var radiusSliderAlpha: CGFloat = 1
		let radiusSliderOffset: CGFloat = 50
		var radiusSliderTransform: CGAffineTransform = CGAffineTransform(translationX: 0, y: -radiusSliderOffset)
		
		toolTip.superview!.superview!.isHidden = false
		bottomToolTip.superview!.superview!.isHidden = false
		
		switch type {
			
		case .path:
			drawingOverlayView.discardsDuplicateClosingPoint = false
			actionButton.isHidden = false
			bufferTitleLabel.text = LocalizedStrings.FlightDrawing.width
			controlPoints.value = []
			state.value = .drawing

		case .point:
			actionButton.isHidden = true
			bufferTitleLabel.text = LocalizedStrings.FlightDrawing.radius
			toolTip.superview!.superview!.isHidden = true
			controlPoints.value = [
				ControlPoint(type: .vertex, coordinate: mapView.centerCoordinate)
			]
			state.value = .panning

		case .polygon:
			drawingOverlayView.discardsDuplicateClosingPoint = true
			actionButton.isHidden = false
			controlPoints.value = []
			radiusSliderTransform = CGAffineTransform.identity
			radiusSliderAlpha = 0
			state.value = .drawing
		}
		
		let animations = {
			self.mapView.logoView.transform = radiusSliderTransform
			self.mapView.attributionButton.transform = radiusSliderTransform
			self.bufferSlider.superview?.transform = radiusSliderTransform.concatenating(CGAffineTransform(translationX: 0, y: radiusSliderOffset))
			self.bufferSlider.superview?.alpha = radiusSliderAlpha
			self.bottomToolTip.superview?.superview?.transform = self.bufferSlider.superview!.transform
		}

		UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState], animations: animations, completion: nil)
	}
	
	func configureForState(_ state: InteractionState) {
	
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
			
			editingOverlayView.clearPath()

			// No existing shape
			if controlPoints.value.count == 0 {
				
				switch selectedGeoType.value {
				case .path:     toolTip.text = localized.toolTipCtaTapToDrawPath
				case .polygon:  toolTip.text = localized.toolTipCtaTapToDrawArea
				case .point:    toolTip.text = localized.toolTipCtaTapToDrawPoint
				}
				
				actionButton.setImage(drawIcon, for: UIControlState())
				actionButton.setImage(drawIconSelected, for: .highlighted)
				actionButton.setImage(drawIconSelected, for: .selected)
				actionButton.addTarget(self, action: #selector(toggleDrawing), for: .touchUpInside)
				
			// Has existing shape
			} else {
				
				let coordinates = controlPoints.value
					.filter { $0.type == .vertex }
					.map { $0.coordinate }
				
				let validation = geometryValidation(selectedGeoType.value, coordinates: coordinates)

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
			
			mapView.isUserInteractionEnabled = true
			drawingOverlayView.isHidden = true
			editingOverlayView.clearPath()
			
			if selectedGeoType.value != .point {
				mapView.hideControlPoints(false)
			}

		case .drawing:
			
			editingOverlayView.clearPath()

			switch selectedGeoType.value {
			case .path:
				toolTip.text = localized.toolTipCtaDrawFreehandPath
				drawingOverlayView.tolerance = 8
			case .polygon:
				toolTip.text = localized.toolTipCtaDrawFreehandArea
				drawingOverlayView.tolerance = 11
			case .point:
				fatalError()
			}
			
			actionButton.setImage(drawIcon, for: UIControlState())
			actionButton.setImage(drawIconSelected, for: .highlighted)
			actionButton.setImage(drawIconSelected, for: .selected)
			actionButton.isSelected = true
			actionButton.isHighlighted = false
			actionButton.addTarget(self, action: #selector(toggleDrawing), for: .touchUpInside)
		
			mapView.isUserInteractionEnabled = false
			drawingOverlayView.isHidden = false
		
		case .editing(let controlPoint):
			
			if canDelete(controlPoint) {
				toolTip.text = localized.toolTipCtaDragToTrashToDelete
			}
			actionButton.setImage(trashIcon, for: UIControlState())
			actionButton.setImage(trashIconHighlighted, for: .highlighted)
			actionButton.setImage(trashIconSelected, for: .selected)
			actionButton.addTarget(self, action: #selector(deleteShape), for: .touchUpInside)
			
			mapView.isUserInteractionEnabled = true
			drawingOverlayView.isHidden = true
			if selectedGeoType.value != .point {
				mapView.hideControlPoints(true)
			}
		case .finished:
			break
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
		selectedGeoType.value = geoType
	}
	
	@objc fileprivate func toggleDrawing() {
		
		switch state.value {
		case .drawing:
			state.value = .panning
		default:
			state.value = .drawing
		}
	}

	@IBAction func deleteShape(_ sender: AnyObject?) {
		
		controlPoints.value = []
		
		if sender is UIButton {
			trackEvent(.tap, label: "Trash Icon")
		}
	}
		
	@IBAction func dismiss() {
		resignFirstResponder()
		trackEvent(.tap, label: "Cancel Button")
		self.dismiss(animated: true, completion: nil)
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
		
		if selectedGeoType.value == .path {
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

		if selectedGeoType.value == .path {
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
		
		switch selectedGeoType.value {
		case .point:
			return false
		case .path:
			return isVertex && vertexCount > 2
		case .polygon:
			return isVertex && vertexCount > 3
		}
	}
	
	fileprivate func geometryValidation(_ geoType: AirMapFlight.FlightGeometryType, coordinates: [CLLocationCoordinate2D]) -> (valid: Bool, kinks: FeatureCollection?) {
		
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
		
		let drawnPoints = Set(points)
		let existingPoints = Set(mapView.annotations?.flatMap({ $0 as? ControlPoint }) ?? [])
		
		let oldPoints = existingPoints.subtracting(drawnPoints)
		mapView.removeAnnotations(Array(oldPoints))
		
		let newPoints = drawnPoints.subtracting(existingPoints)
		mapView.addAnnotations(Array(newPoints))
	}
	
	fileprivate func drawNewProposedRadius(_ radius: Meters = 0) {
		
		guard controlPoints.value.count > 0 else { return }
		
		switch self.selectedGeoType.value {
			
		case .point:
			let centerPoint = controlPoints.value.first!
			state.value = .editing(centerPoint)
			let point = Point(geometry: centerPoint.coordinate)
			let bufferedPoint = SwiftTurf.buffer(point, distance: radius, units: .Meters)
			let proposedCoords = bufferedPoint?.geometry.first ?? []
			let proposedPoints = proposedCoords.map { mapView.convert($0, toPointTo: mapView) }
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
	
	fileprivate func drawFlightArea(_ geoType: AirMapFlight.FlightGeometryType, coordinates: [CLLocationCoordinate2D], buffer: Meters = 0, validation: (valid: Bool, kinks: FeatureCollection?)) {
		
		controlPointsHidden.value = false

		mapView.annotations?
			.filter { ($0 is MGLPolygon || $0 is MGLPolyline || $0 is InvalidIntersection) }
			.forEach { mapView.removeAnnotation($0) }
		
		switch geoType {
			
		case .point:
			guard coordinates.count == 1 else { return }

			let point = AirMapPoint(coordinate: coordinates.first!)
			
			flight.geometry = point
			flight.coordinate = point.coordinate
			flight.buffer = buffer
			
			if let annotations = flight.annotationRepresentations() {
				mapView.addAnnotations(annotations)
			}
			
		case .path:
			guard coordinates.count >= 2 else { return }
			
			let pathGeometry = AirMapPath(coordinates: coordinates)
			
			flight.geometry = pathGeometry
			flight.coordinate = coordinates.first!
			flight.buffer = buffer / 2
			
			if let annotations = flight.annotationRepresentations() {
				mapView.addAnnotations(annotations)
			}
			
		case .polygon:
			guard coordinates.count >= 3 else { return }
			
			let polygonGeometry = AirMapPolygon(coordinates: [coordinates])
			
			flight.geometry = polygonGeometry
			flight.coordinate = coordinates.first!
			flight.buffer = buffer

			if let annotations = flight.annotationRepresentations() {
				mapView.addAnnotations(annotations)
			}
			drawInvalidIntersections(validation.kinks)
		}

		state.value = .panning
	}
	
	fileprivate func drawInvalidIntersections(_ kinks: FeatureCollection?) {
		
		guard let kinks = kinks else { return }
		
		for kink in kinks.features.flatMap({ $0 as? Point }) {
			let invalidIntersection = InvalidIntersection(coordinate: kink.geometry)
			mapView.addAnnotation(invalidIntersection)
		}
	}
			
	fileprivate func centerFlightPlan() {
		if let annotations = mapView.annotations {
			
			let insets: UIEdgeInsets
			switch selectedGeoType.value {
			case .path:
				insets = UIEdgeInsetsMake(80, 45, 70, 45)
			case .polygon:
				insets = UIEdgeInsetsMake(80, 45, 20, 45)
			case .point:
				insets = UIEdgeInsetsMake(10, 45, 60, 45)
			}
			
			mapView.showAnnotations(annotations, edgePadding: insets, animated: true)
		}
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

extension AirMapCreateFlightTypeViewController: DrawingOverlayDelegate {
	
	func overlayDidDraw(geometry: [CGPoint]) {
				
		let coordinates = geometry.map { point in
			mapView.convert(point, toCoordinateFrom: drawingOverlayView)
		}

		// Validate drawn input
		// Discard shapes not meeting minimum/maximum number of points
		switch selectedGeoType.value {
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
			fatalError("Point-based shapes don't draw freehand geometry")
		}
		
		let vertexControlPoints: [ControlPoint] = coordinates.map {
			ControlPoint(type: .vertex, coordinate: $0)
		}
		let midPointControlPoints = self.midPointControlPoints(from: vertexControlPoints)
		var controlPoints = zip(vertexControlPoints, midPointControlPoints).flatMap { [$0.0, $0.1] }
		
		if selectedGeoType.value == .path {
			controlPoints.append(vertexControlPoints.last!)
		}
		
		self.controlPoints.value = controlPoints
		
		state.value = .panning

		centerFlightPlan()		
	}
}

extension AirMapCreateFlightTypeViewController: ControlPointDelegate {
	
	func didStartDragging(_ controlPoint: ControlPointView) {
		
		mapView.hideControlPoints(true)
	}
	
	func didDrag(_ controlPointView: ControlPointView, to point: CGPoint) {
		
		guard let controlPoint = controlPointView.controlPoint else { return }
		let controlPointCoordinate = mapView.convert(point, toCoordinateFrom: mapView)
		
		state.value = .editing(controlPoint)
		
		// shrink the control point so that the drag can break out sooner
		UIView.performWithoutAnimation { 
			controlPointView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
		}
		
		switch selectedGeoType.value {
		
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
				if actionButton.bounds.contains(point) {
					actionButton.isHighlighted = false
					actionButton.isSelected = true
				}
			}
		}
	}
	
	func didEndDragging(_ controlPointView: ControlPointView) {
		
		controlPointView.transform = CGAffineTransform.identity

		guard let controlPoint = controlPointView.controlPoint else { return }
		
		switch selectedGeoType.value {
		
		case .path, .polygon:
			
			if selectedGeoType.value == .path {
				trackEvent(.drag, label: "Drag Path Point")
			}
			
			if selectedGeoType.value == .polygon {
				trackEvent(.drag, label: "Drag Polygon Point")
			}
		
			let hitPoint = mapView.convert(controlPoint.coordinate, toPointTo: mapView)
			let shouldDeletePoint = canDelete(controlPoint) && actionButton.bounds.contains(hitPoint)

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
		editingOverlayView.clearPath()
		state.value = .panning
	}

}
