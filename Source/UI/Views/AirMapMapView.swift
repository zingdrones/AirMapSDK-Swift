//
//  AirMapMapView.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/20/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit
import Mapbox
import RxSwift
import ObjectMapper
import GLKit

open class AirMapMapView: MGLMapView {
	
	public static let defaultTheme: AirMapMapTheme = .light
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	
	// MARK: - Internal

	let drawingOverlay = AirMapDrawingOverlayView()
	let editingOverlay = AirMapEditingOverlayView()
	
	// MARK: - Setup
	
	func setup() {
		
		guard let mapboxAccessToken = AirMap.configuration.mapboxAccessToken else {
			fatalError("A Mapbox access token is required to use the AirMap SDK UI map components.")
		}
		
		MGLAccountManager.setAccessToken(mapboxAccessToken)
		
		let image = UIImage(named: "info_icon", in: AirMapBundle.ui, compatibleWith: nil)!
		attributionButton.setImage(image.withRenderingMode(.alwaysOriginal), for: UIControlState())
		
		setupOverlays()
		
		gestureRecognizers?.forEach({ (recognizer) in
			recognizer.delegate = self
		})
	}
	
	func setupOverlays() {
		
		[drawingOverlay, editingOverlay].forEach { overlay in
			overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			overlay.frame = bounds
			overlay.isHidden = true
			addSubview(overlay)
		}
		
		drawingOverlay.isMultipleTouchEnabled = false
		drawingOverlay.backgroundColor = UIColor.airMapDarkGray.withAlphaComponent(0.333)
		editingOverlay.backgroundColor = .clear
		editingOverlay.isUserInteractionEnabled = false
	}
		
	// MARK: - Configure
	
	
	/// Configures the map with the provided rulesets, adding and removing layers as necessary
	///
	/// - Parameter ruleSets: an array of rulesets
	public func configure(ruleSets: [AirMapRuleSet]) {
		
		guard let style = style else { return }
		
		let ruleSetSourceIds = ruleSets
			.map { $0.tileSourceIdentifier }
		
		let existingRuleSetSourceIds = style.sources
			.flatMap { $0 as? MGLVectorSource }
			.flatMap { $0.identifier }
			.filter { $0.hasPrefix("airmap_ruleset_") }
		
		// Remove orphaned rule set sources
		Set(existingRuleSetSourceIds)
			.subtracting(ruleSetSourceIds)
			.forEach(removeRuleSet)
		
		// Add new sources
		let newSourceIds = Set(ruleSetSourceIds).subtracting(existingRuleSetSourceIds)
		ruleSets
			.filter { newSourceIds.contains($0.tileSourceIdentifier) }
			.forEach(addRuleSet)
		
		updateTemporalFilters()
	}
	
	/// Getter for the jurisidiction present in the map's view port / bounding box
	///
	/// - Returns: an array of AirMapJurisdiction
	public func visibleJurisdictions() -> [AirMapJurisdiction] {
		
		let visibleJurisdictionFeatures = visibleFeatures(in: bounds, styleLayerIdentifiers: ["jurisdictions"])
		
		let visibleJurisdictions = visibleJurisdictionFeatures
			.flatMap { $0.attributes["jurisdiction"] as? String }
			.flatMap { Mapper<AirMapJurisdiction>(context: DataOrigin.tileService).map(JSONString: $0) }
			.filter { $0.ruleSets.count > 0 }
		
		let uniqueJurisdictions = Array(Set(visibleJurisdictions))
		
		return uniqueJurisdictions
	}
	
	
	public func zoomToDraftFlightPlan(with padding: UIEdgeInsets, duration: TimeInterval) {
		
		if let collection = draftFlightSource?.shape as? MGLShapeCollectionFeature {
			let polygon = collection.shapes.flatMap { $0 as? MGLPolygonFeature }.first
			if let bounds = polygon?.overlayBounds {
				let camera = cameraThatFitsCoordinateBounds(bounds, edgePadding: padding)
				setCamera(camera, withDuration: duration, animationTimingFunction: nil)
			}
		}
	}
	
	public func zoomToSpan(of meters: Meters, duration: TimeInterval) {
		
		let metersPerPoint = self.metersPerPoint(atLatitude: centerCoordinate.latitude)
		let points = CGFloat(meters/metersPerPoint)
		let rect = CGRect(x: center.x, y: center.y, width: 0, height: 0)
		let bufferedRect = rect.insetBy(dx: -(points/2), dy: -(points/2))
		let bounds = convert(bufferedRect, toCoordinateBoundsFrom: self)
		let camera = cameraThatFitsCoordinateBounds(bounds)
		setCamera(camera, withDuration: duration, animationTimingFunction: nil)
	}
	
	// MARK: - View Lifecycle
	
	open override func layoutSubviews() {
		super.layoutSubviews()
		
		// Ensure the editing view remains below the annotations view
		if let mapGLKView = subviews.first(where: {$0 is GLKView }) {
			mapGLKView.insertSubview(editingOverlay, at: 0)
		}
		bringSubview(toFront: drawingOverlay)
	}
	
	// MARK: - Private

	private func removeRuleSet(_ identifier: String) {
		
		guard let style = style else { return }
		
		// Style layers must be removed first before removing source
		style.layers
			.flatMap { $0 as? MGLVectorStyleLayer }
			.filter { $0.sourceIdentifier == identifier }
			.forEach(style.removeLayer)
		
		if let source = style.source(withIdentifier: identifier) {
			AirMap.logger.debug("Removing", identifier)
			style.removeSource(source)
		}
	}
	
	private func addRuleSet(_ ruleSet: AirMapRuleSet) {
		
		guard let style = style else {
			return AirMap.logger.error("Style not yet loaded. Unable to add rule set")
		}
		
		guard style.source(withIdentifier: ruleSet.tileSourceIdentifier) == nil else {
			return AirMap.logger.error("Style already contains ruleset; Skipping", ruleSet.id)
		}
		
		let ruleSetTileSource = MGLVectorSource(ruleSet: ruleSet)
		style.addSource(ruleSetTileSource)
		
		AirMap.logger.debug("Adding", ruleSetTileSource.identifier)
		
		style.airMapBaseStyleLayers
			.filter { ruleSet.layers.contains($0.airspaceType!.rawValue) }
			.forEach { baseLayerStyle in
				if let newLayerStyle = newLayerClone(of: baseLayerStyle, with: ruleSet, from: ruleSetTileSource) {
					style.insertLayer(newLayerStyle, above: baseLayerStyle)
				} else {
					AirMap.logger.error("Could not add layer:", baseLayerStyle.sourceLayerIdentifier ?? "?")
				}
		}
	}
	
	private func updateTemporalFilters() {
		
		style?.layers
			.filter { $0.identifier.hasPrefix("airmap|tfr") }
			.flatMap { $0 as? MGLVectorStyleLayer }
			.forEach({ (layer) in
				let start = Int(Date().addingTimeInterval(60*60*4).timeIntervalSince1970)
				let end = Int(Date().timeIntervalSince1970)
				layer.predicate = NSPredicate(format: "start < %i && end > %i", start, end)
			})
	}
}

extension AirMapMapView: UIGestureRecognizerDelegate {
	
	public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		if drawingOverlay.isHidden {
			return true
		} else {
			return false
		}
	}
}

extension AirMapRuleSet {
	
	var tileSourceIdentifier: String {
		return "airmap_ruleset_" + id
	}
}

// Deprecated
extension AirMapMapView {

	@available (*, unavailable, message: "Init map then configure with rulesets")
	public convenience init(frame: CGRect, layers: [AirMapLayerType], theme: AirMapMapTheme) {
		fatalError()
	}

	@available (*, unavailable, message: "Configure map using rulesets")
	public func configure(layers: [AirMapLayerType], theme: AirMapMapTheme) {}
	
}

import SwiftTurf

extension AirMapMapView {
	
	public var draftFlightSource: MGLShapeSource? {
		return style?.source(withIdentifier: "draft-flight-source") as? MGLShapeSource
	}
	
	public var draftFlightFillLayer: MGLFillStyleLayer? {
		return style?.layer(withIdentifier: "draft-flight|fill") as? MGLFillStyleLayer
	}
	
	public func setupDraftFlightSource() {
		
		guard self.draftFlightSource == nil else { return }
		
		let draftFlightSource = MGLShapeSource(identifier: "draft-flight-source", shape: nil, options: nil)
		style?.addSource(draftFlightSource)
		
		let fill = MGLFillStyleLayer(identifier: "draft-flight|fill", source: draftFlightSource)
		fill.fillColor = MGLStyleValue<UIColor>(rawValue: .airMapDarkGray)
		fill.predicate = NSPredicate(format: "%K == %@", "$type", "Polygon")
		fill.fillOpacity = MGLStyleValue<NSNumber>(rawValue: 0.5)
		style?.addLayer(fill)
		
		let line = MGLLineStyleLayer(identifier: "draft-flight|line", source: draftFlightSource)
		line.predicate = NSPredicate(format: "%K == %@", "shows_stroke", NSNumber(booleanLiteral: true))
		line.lineColor = MGLStyleValue<UIColor>(rawValue: .airMapDarkGray)
		line.lineWidth = MGLStyleValue<NSNumber>(rawValue: 2.5)
		style?.addLayer(line)
	}
	
	public func updateDraftFlightPlan(geometry: AirMapGeometry?, buffer: Meters = 0) {
		
		guard let draftFlightSource = draftFlightSource else {
			return
		}
		
		guard let geometry = geometry else {
			draftFlightSource.shape = nil
			return
		}
		
		switch geometry {
			
		case let point as AirMapPoint:
			
			let point = Point(geometry: point.coordinate)
			guard let bufferedPoint = SwiftTurf.buffer(point, distance: buffer, units: .Meters) else { return }
			var coordinates = bufferedPoint.geometry.first!
			let circlePolygon = MGLPolygonFeature(coordinates: &coordinates, count: UInt(coordinates.count))
			circlePolygon.attributes["shows_stroke"] = true
			
			draftFlightSource.shape = circlePolygon
			
		case let path as AirMapPath:
			
			let path = LineString(geometry: path.coordinates)
			guard let bufferedPath = SwiftTurf.buffer(path, distance: buffer/2) else { return }
			
			var outerCoordinates = bufferedPath.geometry.first!
			
			var interiorPolygons: [MGLPolygon] = bufferedPath.geometry.map {
				var coordinates = $0
				return MGLPolygonFeature(coordinates: &coordinates, count: UInt(coordinates.count))
			}
			interiorPolygons.removeFirst()
			
			let bufferPolygon = MGLPolygonFeature(coordinates: &outerCoordinates, count: UInt(outerCoordinates.count), interiorPolygons: interiorPolygons)
			
			let lineStringFeature = MGLPolylineFeature(coordinates: path.geometry, count: UInt(path.geometry.count))
			lineStringFeature.attributes["shows_stroke"] = true
			
			let featureCollection = MGLShapeCollectionFeature(shapes: [bufferPolygon, lineStringFeature])
			draftFlightSource.shape = featureCollection
			
		case let area as AirMapPolygon:
			
			var polygons = area.coordinates!
			
			var outer = polygons.first!
			outer.append(outer.first!)
			
			let fill: MGLPolygonFeature
			let strokes: [MGLPolylineFeature]
			
			if polygons.count == 1 {
				fill = MGLPolygonFeature(coordinates: &outer, count: UInt(outer.count))
				let stroke = MGLPolylineFeature(coordinates: &outer, count: UInt(outer.count))
				stroke.attributes["shows_stroke"] = true
				strokes = [stroke]
			} else {
				let interiorPolygons: [MGLPolygonFeature] = polygons[1..<polygons.count].map {
					var coords = $0
					return MGLPolygonFeature(coordinates: &coords, count: UInt(coords.count))
				}
				fill = MGLPolygonFeature(coordinates: &outer, count: UInt(outer.count), interiorPolygons: interiorPolygons)
				strokes = interiorPolygons.map { polygon in
					let stroke = MGLPolylineFeature(coordinates: polygon.coordinates, count: UInt(interiorPolygons.count))
					stroke.attributes["shows_stroke"] = true
					return stroke
				}
			}
			
			let featureCollection = MGLShapeCollectionFeature(shapes: [fill] + strokes)
			draftFlightSource.shape = featureCollection
			
		default:
			break
		}
	}
}
