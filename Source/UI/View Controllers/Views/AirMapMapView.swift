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
import RxCocoa

/// Delegate for AirMapMapView that provides the registered delegate with updated map information
public protocol AirMapMapViewDelegate: MGLMapViewDelegate {
	
	/// Delegate callback that fires whenever the map's jurisdictions have changed
	///
	/// - Parameters:
	///   - mapView: The instance that triggered the callback
	///   - jurisdictions: The jurisdictions that intersect the map's viewport
	func airMapMapViewJurisdictionsDidChange(mapView: AirMapMapView, jurisdictions: [AirMapJurisdiction])
	
	/// Delegate callback that fires whenever the map's region has changed and the map has finished computing the
	/// intersecting jurisdictions and active rulesets.
	///
	/// - Parameters:
	///   - mapView: The instance that triggered the callback
	///   - jurisdictions: The jurisdictions that intersect the map's viewport
	///   - activeRulesets: The active rulesets that intersect the map's viewport
	func airMapMapViewRegionDidChange(mapView: AirMapMapView, jurisdictions: [AirMapJurisdiction], activeRulesets: [AirMapRuleset])
}

/// Principal view for displaying airspace information spatially on a map
open class AirMapMapView: MGLMapView {
	
	/// Theme that determines the visual style of the map
	public enum Theme: String {
		case standard
		case dark
		case light
		case satellite
	}
	
	/// The current map theme. Default: `.standard`
	public var theme: Theme = .standard {
		didSet { configure(for: theme) }
	}
	
	/// The configuration the map uses to determine the behavior by which the map configures itself
	///
	/// - automatic: The map will be configured automatically. All `.required` rulesets will be enabled, and the default
	///      `.pickOne` rulesets will be enabled. None of the `.optional` rulesets will be enabled except for "AirMap
	///      Recommended" rulesets which are always be enabled.
	/// - dynamic: The map will use the provided list of `preferredRulesetIds` to enable any `.optional` and `.pickOne`
	///      rulesets as they are encountered. If `enableRecommendedRulesets` is false, none of the `.optional`
	///      "AirMap Recommended" rulesets will be enabled, unless it is the only ruleset for a jurisdiction.
	/// - manual: The map will be configured with only the rulesets provided. It is the caller's responsibility to query
	///      the map for jurisdictions and make a determination as to which rulesets to display. The caller should
	///      reconfigure the map accordingly as the map's jurisdictions change. See: `AirMapMapViewDelegate`
	public enum Configuration {
		case automatic
		case dynamic(preferredRulesetIds: [AirMapRulesetId], enableRecommendedRulesets: Bool)
		case manual(rulesets: [AirMapRuleset])		
	}
	
	/// The current ruleset configuration that determines the behavior in which the map configures itself
	public var configuration: Configuration = .automatic {
		didSet { configurationSubject.onNext(configuration) }
	}
	
	/// All jurisidictions intersecting the map's bounds/viewport. Each jurisdiction also provides the rulesets
	/// available within the jurisdiction even if they are not enabled or visible on the map
	public var jurisdictions: [AirMapJurisdiction] {
		return jurisdictions(intersecting: bounds)
	}
	
	/// The rulesets that the map is currently displaying
	public var activeRulesets: [AirMapRuleset] {
		return AirMapMapView.activeRulesets(from: jurisdictions, using: configuration)
	}
	
	// MARK: - Init
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	
	// MARK: - Private

	private let configurationSubject = PublishSubject<Configuration>()
	private let delegateDisposeBag = DisposeBag()
	private var disposeBag = DisposeBag()
}

// MARK: - Private

extension AirMapMapView {
	
	// MARK: - Setup
	
	private func setup() {
		
		setupAccessToken()
		setupBindings()
		setupMap()
	}
	
	private func setupAccessToken() {
		
		guard let token = AirMap.configuration.mapboxAccessToken else {
			fatalError("A Mapbox access token is required to use the AirMap SDK UI map component. " +
				"https://www.mapbox.com/help/define-access-token/")
		}
		MGLAccountManager.setAccessToken(token)
	}
	
	private func setupBindings() {
		
		// Observe the delegate and re-setup bindings
		rx.observeWeakly(MGLMapViewDelegate.self, "delegate", options: [.new]).startWith(nil)
			.filter { delegate in
				delegate == nil || (delegate != nil && !(delegate! is RxMGLMapViewDelegateProxy))
			}
			.distinctUntilChanged(===)
			.observeOn(MainScheduler.asyncInstance)
			.subscribeNext(weak: self, AirMapMapView.configureBindings)
			.disposed(by: delegateDisposeBag)
	}

	private func setupMap() {
		
		let image = UIImage(named: "info_icon", in: AirMapBundle.ui, compatibleWith: nil)!
		attributionButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
		
		isPitchEnabled = false
		allowsRotating = false

		configure(for: theme)
	}
	
	// MARK: - Configuration
	
	private func configureBindings(with delegate: MGLMapViewDelegate?) {
		
		disposeBag = DisposeBag()

		// Perform additional configuration after a style has finished loading
		rx.mapDidFinishLoadingStyle
			.map { $0.style }
			.subscribe(onNext: { (style) in
				style.localizeLabels()
                style.addAirMapSource()                
			})
			.disposed(by: disposeBag)
		
		// Update the style's temporal layers after the loads and periodically after an interval
		rx.mapDidFinishLoadingStyle
			.map { $0.style }
			.repeatLatest(interval: Constants.Maps.temporalLayerRefreshInterval, scheduler: MainScheduler.instance)
			.subscribe(weak: self, onNext: AirMapMapView.updateTemporalFilters)
			.disposed(by: disposeBag)

		// Get the latest jurisdictions as the map region changes
		let latestJurisdictions = rx.regionIsChanging
			.throttle(1, scheduler: MainScheduler.instance)
			.map { $0.jurisdictions }
			.distinctUntilChanged(==)
			.share()
		
		let latestConfiguration = configurationSubject.startWith(configuration)
		
		rx.mapDidFinishLoading
			.flatMapLatest { (mapView) in
				Observable.combineLatest(latestJurisdictions, latestConfiguration)
					.debounce(0.1, scheduler: MainScheduler.asyncInstance)
					.then(onNext: { (jurisdictions, configuration) in

						// Configure the map with the relevant rulesets after a change in map state
						let activeRulesets = AirMapMapView.activeRulesets(from: jurisdictions, using: configuration)
						mapView.configure(with: activeRulesets)
						
						// Notify the delegate that the region has change and active rulesets have been computed
						if let airMapMapViewDelegate = mapView.rx.delegate.forwardToDelegate() as? AirMapMapViewDelegate {
							airMapMapViewDelegate.airMapMapViewRegionDidChange(mapView: mapView, jurisdictions: jurisdictions, activeRulesets: activeRulesets)
						}
					})
			}
			.subscribe()
			.disposed(by: disposeBag)
		
		latestJurisdictions
			.subscribe(onNext: { [unowned self] (jurisdictions) in
				// Notify the delegate that the jurisdictions have changed
				if let airMapMapViewDelegate = self.rx.delegate.forwardToDelegate() as? AirMapMapViewDelegate {
					airMapMapViewDelegate.airMapMapViewJurisdictionsDidChange(mapView: self, jurisdictions: jurisdictions)
				}
			})
			.disposed(by: disposeBag)
	}
	
	private func configure(for theme: Theme) {

		styleURL = Constants.Maps.styleUrl.appendingPathComponent(theme.rawValue+".json")
	}
	
	private func configure(with rulesets: [AirMapRuleset]) {
		
		guard let style = style else { return }
		
		let rulesetSourceIds = rulesets
            .filter { $0.airspaceTypes.count > 0 }
			.map { $0.tileSourceIdentifier }
		
		let existingSourceIds = style.sources
			.flatMap { $0 as? MGLVectorSource }
			.flatMap { $0.identifier }
			.filter { $0.hasPrefix(Constants.Maps.rulesetSourcePrefix) }
		
		let orphanedSourceIds = Set(existingSourceIds).subtracting(rulesetSourceIds)
		let newSourceIds = Set(rulesetSourceIds).subtracting(existingSourceIds)
		
		// Remove orphaned ruleset sources
		orphanedSourceIds.forEach(removeRuleset)
		
		// Add new ruleset sources
		rulesets
			.filter { newSourceIds.contains($0.tileSourceIdentifier) }
			.forEach(addRuleset)
	}
	
	// MARK: - Getters
	
	private func jurisdictions(intersecting rect: CGRect) -> [AirMapJurisdiction] {
		
		return visibleFeatures(in: rect, styleLayerIdentifiers: [Constants.Maps.jurisdictionsStyleLayerId])
			.flatMap { $0.attributes[Constants.Maps.jurisdictionFeatureAttributesKey] as? String }
			.flatMap { AirMapJurisdiction.tileServiceMapper.map(JSONString: $0) }
			.reduce(into: [AirMapJurisdiction]()) { (array, jurisdiction) in
				if !array.contains(jurisdiction) && !jurisdiction.rulesets.isEmpty {
					array.append(jurisdiction)
				}
		}
	}

	// MARK: - Instance Methods
	
	private func addRuleset(_ ruleset: AirMapRuleset) {
		
		guard let style = style, style.source(withIdentifier: ruleset.tileSourceIdentifier) == nil else { return }
		
		let rulesetTileSource = MGLVectorSource(ruleset: ruleset)
		style.addSource(rulesetTileSource)
		
		style.airMapBaseStyleLayers
			.filter { ruleset.airspaceTypes.contains($0.airspaceType!) }
			.forEach { baseLayer in
				if let newLayerStyle = newLayerClone(of: baseLayer, with: ruleset, from: rulesetTileSource) {
					AirMap.logger.debug("Adding", ruleset.id, baseLayer.identifier)
					style.insertLayer(newLayerStyle, above: baseLayer)
				} else {
					AirMap.logger.error("Could not add layer for", ruleset.id, baseLayer.airspaceType!)
				}
			}
	}
	
	private func removeRuleset(sourceIdentifier: String) {
		
		guard let style = style else { return }
		
		style.layers
			.flatMap { $0 as? MGLVectorStyleLayer }
			.filter { $0.sourceIdentifier == sourceIdentifier }
			.forEach(style.removeLayer)
		
		if let source = style.source(withIdentifier: sourceIdentifier) {
			AirMap.logger.debug("Removing", sourceIdentifier)
			style.removeSource(source)
		}
	}
	
	/// Updates the predicates for temporal layers such as .tfr and .notam with a near future time window
	private func updateTemporalFilters(in style: MGLStyle) {
		
		let temporalAirspaces: [AirMapAirspaceType] = [.tfr, .notam]
		
		style.layers
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
	
	// MARK: - Static
	
	private static func activeRulesets(from jurisdictions: [AirMapJurisdiction], using configuration: Configuration) -> [AirMapRuleset] {
		
		switch configuration {
			
		case .automatic:
			return AirMapRulesetResolver.resolvedActiveRulesets(
				with: [],
				from: jurisdictions,
				enableRecommendedRulesets: true
			)
		case .dynamic(let preferredRulesetIds, let enableRecommendedRulesets):
			return AirMapRulesetResolver.resolvedActiveRulesets(
				with: preferredRulesetIds,
				from: jurisdictions,
				enableRecommendedRulesets: enableRecommendedRulesets
			)
		case .manual(let rulesets):
			return rulesets
		}
	}
}

// MARK: - Extensions

extension AirMapRuleset {
	
	var tileSourceIdentifier: String {
		return Constants.Maps.rulesetSourcePrefix + id.rawValue
	}
}

// MARK: - Helpers

public class AirMapRulesetResolver {
	
	/// Takes a list of ruleset preferences and resolve which rulesets should be enabled from the available jurisdictions
	///
	/// - Parameters:
	///   - preferredRulesetIds: An array of rulesets ids, if any, that the user has previously selected
	///   - jurisdictions: An array of jurisdictions for the area of operation
	///   - recommendedEnabledByDefault: A flag that enables all recommended airspaces by default.
	/// - Returns: A resolved array of rulesets taking into account the user's .optional and .pickOne selection preference
	public static func resolvedActiveRulesets(with preferredRulesetIds: [AirMapRulesetId], from jurisdictions: [AirMapJurisdiction], enableRecommendedRulesets: Bool) -> [AirMapRuleset] {
		
		var rulesets = [AirMapRuleset]()
		
		// always include the required rulesets (e.g. TFRs, restricted areas, etc)
		rulesets += jurisdictions.requiredRulesets
		
		// if the preferred rulesets contains an .optional ruleset, add it to the array
		rulesets += jurisdictions.optionalRulesets
			.filter({ !jurisdictions.airMapRecommendedRulesets.contains($0) })
			.filter({ preferredRulesetIds.contains($0.id)})
		
		// if the preferred rulesets contains an .optional AirMap recommended ruleset, add it to the array
		// if the only ruleset is an AirMap recommended ruleset, add it as well
		rulesets += jurisdictions.airMapRecommendedRulesets
			.filter({ enableRecommendedRulesets || preferredRulesetIds.contains($0.id) || jurisdictions.rulesets.count == 1 })
		
		// for each jurisdiction, determine if a preferred .pickOne has been selected otherwise take the default .pickOne
		for jurisdiction in jurisdictions {
			guard let defaultPickOneRuleset = jurisdiction.defaultPickOneRuleset else { continue }
			if let preferredPickOne = jurisdiction.pickOneRulesets.first(where: { preferredRulesetIds.contains($0.id) }) {
				rulesets.append(preferredPickOne)
			} else {
				rulesets.append(defaultPickOneRuleset)
			}
		}
		
		return rulesets
	}
	
}
