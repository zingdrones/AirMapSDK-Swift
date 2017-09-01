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
	
	/// The theme that is enabled by default. Standard street-based styling.
	public static let defaultTheme: AirMapMapTheme = .standard

	/// The current map theme that controls the styling of the map
	public var theme: AirMapMapTheme = AirMapMapView.defaultTheme {
		didSet { self.styleURL = styleUrl(for: theme) }
	}
	
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
	/// - Parameter rulesets: an array of rulesets
	public func configure(rulesets: [AirMapRuleset]) {
		
		guard let style = style else {
			AirMap.logger.error("Map must be complete initialization before configuring with rulesets")
			return
		}
		
		let rulesetSourceIds = rulesets
			.map { $0.tileSourceIdentifier }
		
		let existingRulesetSourceIds = style.sources
			.flatMap { $0 as? MGLVectorSource }
			.flatMap { $0.identifier }
			.filter { $0.hasPrefix(Config.Maps.rulesetSourcePrefix) }
		
		// Remove orphaned ruleset sources
		Set(existingRulesetSourceIds)
			.subtracting(rulesetSourceIds)
			.forEach(removeRuleset)
		
		// Add new sources
		let newSourceIds = Set(rulesetSourceIds).subtracting(existingRulesetSourceIds)
		rulesets
			.filter { newSourceIds.contains($0.tileSourceIdentifier) }
			.forEach(addRuleset)
		
		updateTemporalFilters()
	}
	
	/// Getter for the jurisidiction present in the map's view port / bounding box
	///
	/// - Returns: an array of AirMapJurisdiction
	public func visibleJurisdictions() -> [AirMapJurisdiction] {
		
		let visibleJurisdictionFeatures = visibleFeatures(in: bounds, styleLayerIdentifiers: ["jurisdictions"])
		
		let visibleJurisdictions = visibleJurisdictionFeatures
			.flatMap { $0.attributes["jurisdiction"] as? String }
			.flatMap { (json: String) in
				print(json)
				return Mapper<AirMapJurisdiction>(context: AirMapRuleset.Origin.tileService).map(JSONString: json)
			}
			.filter { (jurisdiction: AirMapJurisdiction) in jurisdiction.rulesets.count > 0 }
		
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

	private func addRuleset(_ ruleset: AirMapRuleset) {
		
		guard let style = style else {
			return AirMap.logger.error("Style not yet loaded. Unable to add ruleset", ruleset.id)
		}
		
		guard style.source(withIdentifier: ruleset.tileSourceIdentifier) == nil else {
			return AirMap.logger.error("Style already contains ruleset; Skipping", ruleset.id)
		}
		
		let rulesetTileSource = MGLVectorSource(ruleset: ruleset)
		style.addSource(rulesetTileSource)
		
		AirMap.logger.debug("Adding", rulesetTileSource.identifier)
		
		style.airMapBaseStyleLayers
			.filter { ruleset.airspaceTypeIds.contains($0.airspaceType!.rawValue) }
			.forEach { baseLayerStyle in
				if let newLayerStyle = newLayerClone(of: baseLayerStyle, with: ruleset, from: rulesetTileSource) {
					style.insertLayer(newLayerStyle, above: baseLayerStyle)
				} else {
					AirMap.logger.error("Could not add layer:", baseLayerStyle.sourceLayerIdentifier ?? "–")
				}
		}
	}

	private func removeRuleset(_ identifier: String) {
		
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
	
	/// Constructs a styleUrl based on the AirMap Theme
	private func styleUrl(for theme: AirMapMapTheme) -> URL {
		return try! (Config.AirMapApi.mapStylePath+"\(theme.rawValue).json").asURL()
	}

}

extension AirMapRuleset {
	
	var tileSourceIdentifier: String {
		return Config.Maps.rulesetSourcePrefix + id
	}
}
