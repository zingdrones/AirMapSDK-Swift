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

		newLayer.sourceLayerIdentifier = ruleset.id.rawValue + "_" + existingLayer.airspaceType!.rawValue
		
		properties.forEach { key in
			let baseValue = existingLayer.value(forKey: key)
			newLayer.setValue(baseValue, forKey: key)
		}
		
		return newLayer
	}
		
}

extension MGLStyle {
	
	var airMapBaseStyleLayers: [MGLVectorStyleLayer] {
        
        let vectorLayers = layers.flatMap { $0 as? MGLVectorStyleLayer }
        let compositeLayers = vectorLayers.filter { $0.sourceIdentifier == "airmap" }
        let airMapBaseLayers = compositeLayers
            .filter { $0.identifier.hasPrefix("airmap") }
            .filter { $0.airspaceType != nil }
        
        assert(airMapBaseLayers.count != 0)

        return airMapBaseLayers
	}
	
	var activeAirMapStyleLayers: [MGLVectorStyleLayer] {
		return layers
			.flatMap { $0 as? MGLVectorStyleLayer }
			.filter { $0.sourceIdentifier?.hasPrefix(Constants.Maps.rulesetSourcePrefix) ?? false }
	}
	    
    /// Updates the map labels to one of the supported languages
    func localizeLabels() {
        
        let currentLanguage = Locale.current.languageCode ?? "en"
        let supportedLanguages = ["en", "es", "de", "fr", "ru", "zh"]
        let supportsCurrentLanguage = supportedLanguages.contains(currentLanguage)
        
        let labelLayers = layers.flatMap { $0 as? MGLSymbolStyleLayer }
        
        for layer in labelLayers {
            if let textValue = layer.text as? MGLConstantStyleValue {
                let nameField: String
                if supportsCurrentLanguage {
                    nameField = "{name_\(currentLanguage)}"
                } else {
                    nameField = "{name}"
                }
                let newValue = textValue.rawValue.replacingOccurrences(of: "{name_en}", with: nameField)
                layer.text = MGLStyleValue(rawValue: newValue as NSString)
            }
        }
    }
        
    /// Update the predicates for temporal layers such as .tfr and .notam with a near future time window
    func updateTemporalFilters() {
        
        let temporalAirspaces: [AirMapAirspaceType] = [.tfr, .notam]
        
        layers
            .filter { $0.identifier.hasPrefix(Constants.Maps.airmapLayerPrefix) && temporalAirspaces.contains($0.airspaceType!) }
            .flatMap { $0 as? MGLVectorStyleLayer }
            .forEach({ (layer) in
                let now = Int(Date().timeIntervalSince1970)
                let nearFuture = Int(Date().timeIntervalSince1970 + Constants.Maps.futureTemporalWindow)
                let overlapsWithNow = NSPredicate(format: "start < %i && end > %i", now, now)
                let startsSoon = NSPredicate(format: "start > %i && end < %i", now, nearFuture)
                let isPermanent = NSPredicate(format: "permanent == YES")
                let hasNoEnd = NSPredicate(format: "end == NULL")
                let isNotBase = NSPredicate(format: "base == NULL")
                let timePredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [overlapsWithNow, startsSoon, isPermanent, hasNoEnd])
                layer.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [timePredicate, isNotBase])
            })
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
		
		let layerNames = ruleset.airspaceTypes.map { $0.rawValue }.joined(separator: ",")
		let options = [
			MGLTileSourceOption.minimumZoomLevel: NSNumber(value: Constants.Maps.tileMinimumZoomLevel),
			MGLTileSourceOption.maximumZoomLevel: NSNumber(value: Constants.Maps.tileMaximumZoomLevel)
		]
		let sourcePath = Constants.AirMapApi.tileDataUrl + "/\(ruleset.id)/\(layerNames)/{z}/{x}/{y}?apikey=\(AirMap.configuration.airMapApiKey)"
		
		self.init(identifier: ruleset.tileSourceIdentifier, tileURLTemplates: [sourcePath], options: options)
	}
}

extension MGLCoordinateBounds {
	
	// Convert the bounding box into a polygon; remembering to close the polygon by passing the first point again
	public var geometry: AirMapPolygon {
		let nw = CLLocationCoordinate2D(latitude: ne.latitude, longitude: sw.longitude)
		let se = CLLocationCoordinate2D(latitude: sw.latitude, longitude: ne.longitude)
		let coordinates = [nw, ne, se, sw, nw]
		return AirMapPolygon(coordinates: [coordinates])
	}
}
