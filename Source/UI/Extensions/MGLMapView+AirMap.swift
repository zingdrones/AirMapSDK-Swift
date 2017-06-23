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
	
	/// Hides mid control points that are in close proximity to control points
	public func hideObscuredMidPointControls() {
		
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
	
	/// Clones an existing MGLVectorstyleLayer and applies a list of known properties to the new instance
	///
	/// - Parameters:
	///   - existingLayer: The layer style to clone and from which to source property values
	///   - ruleSet: The ruleset that defines the classification layers that will back the style layer
	///   - source: The tile source to which associate the layer style
	/// - Returns: Returns a new style styled with the visual properties of the existing layer, and configured with the appropriate source, layer, and ruleset.
	func newLayerClone(of existingLayer: MGLVectorStyleLayer, with ruleSet: AirMapRuleSet, from source: MGLSource) -> MGLVectorStyleLayer? {
		
		let commonProps: [String] = [
			"predicate",
			"visible"
		]
		let lineProps: [String] = [
			// Layout
			"lineCap",
			"lineJoin",
			"lineMiterLimit",
			"lineRoundLimit",
			// Paint
			"lineOpacity",
			"lineColor",
			"lineTranslation",
			"lineTranslationAnchor",
			"lineWidth",
			"lineGapWidth",
			"lineOffset",
			"lineBlur",
			"lineDashPattern",
			"linePattern"
		]
		let fillProps: [String] = [
			"fillOpacity",
			"fillColor",
			"fillPattern"
		]
		let symbolProps: [String] = [
			// Layout
			"symbolPlacement",
			"symbolSpacing",
			"symbolAvoidsEdges",
			"iconAllowsOverlap",
			"iconIgnoresPlacement",
			"iconOptional",
			"iconRotationAlignment",
			"iconScale",
			"iconImageName",
			"iconPadding",
			"keepsIconUpright",
			"text",
			"textFontSize",
			"textFontNames",
			"maximumTextWidth",
			"textLineHeight",
			"textLetterSpacing",
			"textJustification",
			"textAnchor",
			"textPadding",
			"textTransform",
			"textOffset",
			"textAllowsOverlap",
			"textIgnoresPlacement",
			"textOptional",
			// Paint
			"iconOpacity",
			"iconColor",
			"iconHaloColor",
			"iconHaloWidth",
			"iconHaloBlur",
			"iconTranslation",
			"iconTranslationAnchor",
			"textOpacity",
			"textColor",
			"textHaloColor",
			"textHaloWidth",
			"textHaloBlur",
			"textTranslation",
			"textTranslationAnchor"
		]
		
		let uuid = UUID().uuidString
		
		let properties: [String]
		let newLayer: MGLVectorStyleLayer
		
		let layerId = [existingLayer.identifier, uuid].joined(separator: "|")
		
		switch existingLayer {
		case is MGLFillStyleLayer:
			newLayer = MGLFillStyleLayer(identifier: layerId, source: source)
			properties = commonProps+fillProps
		case is MGLLineStyleLayer:
			newLayer = MGLLineStyleLayer(identifier: layerId, source: source)
			properties = commonProps+lineProps
		case is MGLSymbolStyleLayer:
			newLayer = MGLSymbolStyleLayer(identifier: layerId, source: source)
			properties = commonProps+symbolProps
		default:
			print("Unsupported layer type:", existingLayer)
			return nil
		}
		
		newLayer.sourceLayerIdentifier = ruleSet.id + "_" + existingLayer.airspaceType!.rawValue
		
		properties.forEach { key in
			let baseValue = existingLayer.value(forKey: key)
			newLayer.setValue(baseValue, forKey: key)
		}
		
		return newLayer
	}
	
}

extension MGLStyle {
	
	var airMapBaseStyleLayers: [MGLVectorStyleLayer] {
		return layers
			.flatMap { $0 as? MGLVectorStyleLayer }
			.filter { $0.sourceIdentifier == "composite" }
			.filter { $0.identifier.hasPrefix("airmap") }
			.filter { $0.airspaceType != nil }
	}
	
	var activeAirMapStyleLayers: [MGLVectorStyleLayer] {
		return layers
			.flatMap { $0 as? MGLVectorStyleLayer }
			.filter { $0.sourceIdentifier?.hasPrefix("airmap_ruleset") ?? false }
	}
}

extension MGLStyleLayer {
	
	var airspaceType: AirMapAirspaceType? {
		let components = identifier.components(separatedBy: "|")
		if components.count > 1 {
			let typeString = identifier.components(separatedBy: "|")[1]
			return AirMapAirspaceType(rawValue: typeString)
		} else {
			return nil
		}
	}
}

extension MGLVectorSource {
	
	convenience init(ruleSet: AirMapRuleSet) {
		
		let layerNames = ruleSet.layers.map{$0}.joined(separator: ",")
		let options = [
			MGLTileSourceOption.minimumZoomLevel: NSNumber(value: Config.Maps.tileMinimumZoomLevel),
			MGLTileSourceOption.maximumZoomLevel: NSNumber(value: Config.Maps.tileMaximumZoomLevel)
		]
		let urlTemplate = "https://api.airmap.com/tiledata/stage/\(ruleSet.id)/\(layerNames)/{z}/{x}/{y}?apikey=\(AirMap.configuration.airMapApiKey!)"
		
		self.init(identifier: ruleSet.tileSourceIdentifier, tileURLTemplates: [urlTemplate], options: options)
	}
}
