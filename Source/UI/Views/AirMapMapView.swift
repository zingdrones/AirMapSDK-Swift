//
//  AirMapMapView.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/20/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit
import Mapbox
import ObjectMapper

open class AirMapMapView: MGLMapView {
	
	public static let defaultTheme: AirMapMapTheme = .standard
	
	// MARK: - Init

	public override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	// MARK: - Configuration
	
	/// Configures the map with the provided rulesets, adding and removing layers as necessary
	///
	/// - Parameter ruleSets: an array of rulesets
	public func configure(ruleSets: [AirMapRuleSet]) {
		
		guard let style = style else {
			AirMap.logger.error("Map must be complete initialization before configuring with ruleSets")
			return
		}
		
		let ruleSetSourceIds = ruleSets
			.map { $0.tileSourceIdentifier }
		
		let existingRuleSetSourceIds = style.sources
			.flatMap { $0 as? MGLVectorSource }
			.flatMap { $0.identifier }
			.filter { $0.hasPrefix(Config.Maps.ruleSetSourcePrefix) }
		
		// Remove orphaned ruleset sources
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
			.flatMap { Mapper<AirMapJurisdiction>(context: AirMapRuleSet.Origin.tileService).map(JSONString: $0) }
			.filter { $0.ruleSets.count > 0 }
		
		let uniqueJurisdictions = Array(Set(visibleJurisdictions))
		
		return uniqueJurisdictions
	}
	
	// MARK: - Private

	private func commonInit() {
		
		guard let mapboxAccessToken = AirMap.configuration.mapboxAccessToken else {
			fatalError("A Mapbox access token is required to use the AirMap SDK UI map components")
		}
		
		MGLAccountManager.setAccessToken(mapboxAccessToken)
		
		let image = UIImage(named: "info_icon", in: AirMapBundle.ui, compatibleWith: nil)!
		attributionButton.setImage(image.withRenderingMode(.alwaysOriginal), for: UIControlState())

		isPitchEnabled = false
		allowsRotating = false
	}

	private func addRuleSet(_ ruleSet: AirMapRuleSet) {
		
		guard let style = style else {
			return AirMap.logger.error("Style not yet loaded. Unable to add ruleset", ruleSet.id)
		}
		
		guard style.source(withIdentifier: ruleSet.tileSourceIdentifier) == nil else {
			return AirMap.logger.error("Style already contains ruleset; Skipping", ruleSet.id)
		}
		
		let ruleSetTileSource = MGLVectorSource(ruleSet: ruleSet)
		style.addSource(ruleSetTileSource)
		
		AirMap.logger.debug("Adding", ruleSetTileSource.identifier)
		
		style.airMapBaseStyleLayers
			.filter { ruleSet.airspaceTypeIds.contains($0.airspaceType!.rawValue) }
			.forEach { baseLayerStyle in
				if let newLayerStyle = newLayerClone(of: baseLayerStyle, with: ruleSet, from: ruleSetTileSource) {
					style.insertLayer(newLayerStyle, above: baseLayerStyle)
				} else {
					AirMap.logger.error("Could not add layer:", baseLayerStyle.sourceLayerIdentifier ?? "–")
				}
		}
	}

	private func removeRuleSet(_ identifier: String) {
		
		guard let style = style else {
			return AirMap.logger.error("Style not yet loaded. Unable to remove ruleset", identifier)
		}

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
	
	/// Updates the predicated for temporal layers such as tfr and notams with a sensible time window
	private func updateTemporalFilters() {
		
		style?.layers
			.filter { $0.identifier.hasPrefix("airmap|tfr") || $0.identifier.hasPrefix("airmap|notam") }
			.flatMap { $0 as? MGLVectorStyleLayer }
			.forEach({ (layer) in
				let now = Int(Date().timeIntervalSince1970)
				let nearFuture = Int(Date().timeIntervalSince1970 + Config.Maps.futureTemporalWindow)
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

extension AirMapRuleSet {
	
	var tileSourceIdentifier: String {
		return Config.Maps.ruleSetSourcePrefix + id
	}
}
