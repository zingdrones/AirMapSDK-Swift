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
	///      Recommended" rulesets which will always be enabled.
	/// - dynamic: The map will use the provided list of preferred ruleset ids to enable any `.optional` and `.pickOne`
	///      rulesets as they are encountered. If `enableRecommendedRulesets` is false, none of the optional
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
	
	/// The AirMap logo in the lower left corner.
	/// If you wish to remove the AirMap wordmark, please contact our sales team to discuss an Enterprise plan
	public var airMapLogoView: UIImageView!
	
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
	private let disposeBag = DisposeBag()
}

// MARK: - Private

extension AirMapMapView {

	// MARK: - Getters

	private var airMapMapViewDelegate: AirMapMapViewDelegate? {
		return rx.delegate.forwardToDelegate() as? AirMapMapViewDelegate
	}
	
	// MARK: - Setup
	
	private func setup() {
		
		setupAccessToken()
		setupBindings()
		setupAppearance()
	}
	
	private func setupAccessToken() {
		
		guard MGLAccountManager.accessToken() == nil else { return }
		
		guard let token = AirMap.configuration.mapboxAccessToken else {
			fatalError("A Mapbox access token is required to use the AirMap SDK UI map component. " +
				"https://www.mapbox.com/help/define-access-token/")
		}
		MGLAccountManager.setAccessToken(token)
	}
	
	private func setupBindings() {
		
		// Ensure we remain the delegate via Rx and any other delegates are set as the forward delegate
		rx.observeWeakly(MGLMapViewDelegate.self, "delegate")

			// Ignore duplicate events of the same delegate object
			.distinctUntilChanged(===)
			
			// Ignore Rx's delegate proxy to prevent infinite recursion
			.filter { !($0 is Optional<RxMGLMapViewDelegateProxy>) }
			
			// ⚠ Observe asynchronously to prevent reentrancy warning since the subscription below sets the delegate
			// this observable chain observes ⚠
			.observeOn(MainScheduler.asyncInstance)
			
			// Reconfigure the following observable chain whenever the delegate is replaced
			.flatMapLatest { [unowned self] _ in
				self.rx.mapDidFinishLoadingStyle
			}
			
			// Reconfigure the following observable chain whenever the style is updated
			.flatMapLatest({ (mapView, style) -> Observable<Void> in
				
				// Localize map labels
				style.localizeLabels()
				
				// Update the style's temporal layers on a set interval
				let configureTemporalLayers = Observable.of(style)
					.repeatWithBehavior(.delayed(maxCount: .max, time: Constants.Maps.temporalLayerRefreshInterval))
					.do(onNext: { (style) in
						style.updateTemporalFilters()
					})
					.mapToVoid()

				// Get the latest jurisdiction on initial map rendering and as the map region changes
				let latestJurisdictions = Observable
					.merge(
						mapView.rx.mapDidFinishRenderingMap
							.map({ $0.mapView })
							.take(1),
						mapView.rx.regionIsChanging
							.throttle(1.0, scheduler: MainScheduler.asyncInstance)
					)
					.observeOn(MainScheduler.asyncInstance)
					.map { $0.jurisdictions }
					.distinctUntilChanged(==)

					// Notify the delegate that the jurisdictions have changed
					.do(onNext: { [unowned mapView] (jurisdictions) in
						mapView.airMapMapViewDelegate?.airMapMapViewJurisdictionsDidChange(mapView: mapView, jurisdictions: jurisdictions)
					})
					.share()

				// Determine the active rulesets from the available jurisdictions and the map configuration
				let activeRulesets = Observable
					.combineLatest(
						latestJurisdictions,
						mapView.configurationSubject.startWith(mapView.configuration)
					)
					.map { (AirMapMapView.activeRulesets(from: $0, using: $1), $0) }

					.do(onNext: { [unowned mapView] (activeRulesets, jurisdictions) in
						// Configure the map with the active rulesets
						mapView.configure(with: activeRulesets)
						// Notify the delegate of the activated rulesets
						mapView.airMapMapViewDelegate?.airMapMapViewRegionDidChange(mapView: mapView, jurisdictions: jurisdictions, activeRulesets: activeRulesets)
					})
					.mapToVoid()
				
				// Return all inner observables to the outer subscription
				return Observable.merge(configureTemporalLayers, activeRulesets)
			})
			.subscribe()
			.disposed(by: disposeBag)
	}

	private func setupAppearance() {
		
		let image = UIImage(named: "info_icon", in: AirMapBundle.ui, compatibleWith: nil)!
		attributionButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
		
		let airMapLogo = UIImage(named: "map_logo", in: AirMapBundle.ui, compatibleWith: nil)
		airMapLogoView = UIImageView(image: airMapLogo)

		logoView.contentMode = .right
		logoView.addSubview(airMapLogoView)
		
		NSLayoutConstraint.activate([
			logoView.rightAnchor.constraint(equalTo: attributionButton.leftAnchor, constant: -6),
			logoView.heightAnchor.constraint(equalToConstant: 23)
			])
		
		isPitchEnabled = false
		allowsRotating = false

		configure(for: theme)
	}
	
	// MARK: - Configuration
	
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
		
		style.airMapBaseStyleLayers(for: ruleset.airspaceTypes)
			.forEach { baseLayer in
				if let newLayer = newLayerClone(of: baseLayer, with: ruleset, from: rulesetTileSource) {
					AirMap.logger.debug("Adding", ruleset.id, baseLayer.identifier)
					var layer = newLayer as MGLStyleLayer
					style.insertLayer(layer, above: baseLayer)
					self.airMapMapViewDelegate?.airMapMapViewDidAddAirspaceType(
						mapView: self, ruleset: ruleset, airspaceType: layer.airspaceType!, layer: &layer
					)
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
			.forEach { layer in
				style.removeLayer(layer)
				self.airMapMapViewDelegate?.airMapMapViewDidRemoveAirspaceType(mapView: self, airspaceType: layer.airspaceType!)
			}
		
		if let source = style.source(withIdentifier: sourceIdentifier) {
			AirMap.logger.debug("Removing", sourceIdentifier)
			style.removeSource(source)
		}
	}	
	
	// MARK: - Static
	
	private static func activeRulesets(from jurisdictions: [AirMapJurisdiction], using configuration: Configuration) -> [AirMapRuleset] {
		
		switch configuration {
			
		case .automatic:
			return AirMapRulesetResolver.resolvedActiveRulesets(from: jurisdictions)
			
		case .dynamic(let ids, let recommended):
			return AirMapRulesetResolver.resolvedActiveRulesets(with: ids, from: jurisdictions, enableRecommendedRulesets: recommended)
			
		case .manual(let rulesets):
			return rulesets
		}
	}
}

// MARK: - Helpers

public class AirMapRulesetResolver {
	
	/// Takes a list of ruleset preferences and resolves which rulesets should be enabled from the available jurisdictions
	///
	/// - Parameters:
	///   - preferredRulesetIds: An array of rulesets ids, if any, that the user has previously selected
	///   - jurisdictions: An array of jurisdictions for the area of operation
	///   - recommendedEnabledByDefault: A flag that enables all recommended airspaces by default.
	/// - Returns: A resolved array of rulesets taking into account the user's .optional and .pickOne selection preference
	public static func resolvedActiveRulesets(with preferredRulesetIds: [AirMapRulesetId] = [], from jurisdictions: [AirMapJurisdiction], enableRecommendedRulesets: Bool = true) -> [AirMapRuleset] {
		
		var rulesets = [AirMapRuleset]()
		
		// always include the required rulesets (e.g. TFRs, restricted areas, etc)
		rulesets += jurisdictions.requiredRulesets
		
		// if the preferred rulesets contains an .optional ruleset, add it to the array
		rulesets += jurisdictions.optionalRulesets
			.filter({ !jurisdictions.airMapRecommendedRulesets.contains($0) })
			.filter({ preferredRulesetIds.contains($0.id) })
		
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
