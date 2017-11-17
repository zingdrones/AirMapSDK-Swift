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
	
	/// Clones an existing MGLVectorstyleLayer and applies a list of known properties to the new instance
	///
	/// - Parameters:
	///   - existingLayer: The layer style to clone and from which to source property values
	///   - ruleset: The ruleset that defines the classification layers that will back the style layer
	///   - source: The tile source to which associate the layer style
	/// - Returns: Returns a new style styled with the visual properties of the existing layer, and configured with the appropriate source, layer, and ruleset.
	func newLayerClone(of existingLayer: MGLVectorStyleLayer, with ruleset: AirMapRuleset, from source: MGLSource) -> MGLVectorStyleLayer? {
		
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
			AirMap.logger.warning("Unsupported layer type:", existingLayer)
			return nil
		}
		
		newLayer.sourceLayerIdentifier = ruleset.id + "_" + existingLayer.airspaceType!.rawValue
		
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
			.filter { $0.sourceIdentifier == "airmap" }
			.filter { $0.airspaceType != nil }
	}
	
	var activeAirMapStyleLayers: [MGLVectorStyleLayer] {
		return layers
			.flatMap { $0 as? MGLVectorStyleLayer }
			.filter { $0.sourceIdentifier?.hasPrefix(Constants.Maps.rulesetSourcePrefix) ?? false }
	}
}

extension MGLStyleLayer {
	
	var airspaceType: AirMapAirspaceType? {
		let components = identifier.components(separatedBy: "|")
		if components.count > 1 {
			return AirMapAirspaceType(rawValue: components[1]) ?? .unclassified
		} else {
			return nil
		}
	}
}

extension MGLVectorSource {
	
	convenience init(ruleset: AirMapRuleset) {
		
		let layerNames = ruleset.airspaceTypeIds.csv
		let options = [
			MGLTileSourceOption.minimumZoomLevel: NSNumber(value: Constants.Maps.tileMinimumZoomLevel),
			MGLTileSourceOption.maximumZoomLevel: NSNumber(value: Constants.Maps.tileMaximumZoomLevel)
		]
		let sourcePath = Constants.AirMapApi.mapSourceUrl + "/\(ruleset.id)/\(layerNames)/{z}/{x}/{y}?apikey=\(AirMap.configuration.airMapApiKey)"
		
		self.init(identifier: ruleset.tileSourceIdentifier, tileURLTemplates: [sourcePath], options: options)
	}
}
