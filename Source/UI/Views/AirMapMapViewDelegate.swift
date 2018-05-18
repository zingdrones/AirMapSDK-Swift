//
//  AirMapMapViewDelegate.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 12/22/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Mapbox

/// Delegate for AirMapMapView that provides the registered delegate with updated map information
public protocol AirMapMapViewDelegate: MGLMapViewDelegate {
	
	/// Optional callback that is called whenever the map's jurisdictions have changed
	///
	/// - Parameters:
	///   - mapView: The map instance associated with the callback event
	///   - jurisdictions: The jurisdictions that intersect the map's viewport
	func airMapMapViewJurisdictionsDidChange(mapView: AirMapMapView, jurisdictions: [AirMapJurisdiction])
	
	/// Optional callback that is called whenever the map's region has changed and the map has finished computing the
	/// intersecting jurisdictions and active rulesets.
	///
	/// - Parameters:
	///   - mapView: The map instance associated with the callback event
	///   - jurisdictions: The jurisdictions that intersect the map's viewport
	///   - activeRulesets: The active rulesets that intersect the map's viewport
	func airMapMapViewRegionDidChange(mapView: AirMapMapView, jurisdictions: [AirMapJurisdiction], activeRulesets: [AirMapRuleset])
	
	/// Optional callback which provides a point of customization for styling AirMap airspace map layers
	///
	/// - Parameters:
	///   - mapView: The map instance associated with the callback event
	///   - ruleset: The ruleset associated with the layer that was added
	///   - airspaceType: The airspace type the layer represents
	///   - layer: The map style layer that was added to the map
	func airMapMapViewDidAddAirspaceType(mapView: AirMapMapView, ruleset: AirMapRuleset, airspaceType: AirMapAirspaceType, layer: inout MGLStyleLayer)
	
	/// Optional callback which is called whenever an airspace type is removed from the map
	///
	/// - Parameters:
	///   - mapView: The map instance associated with the callback event
	///   - airspaceType: The airspace type the layer represented
	func airMapMapViewDidRemoveAirspaceType(mapView: AirMapMapView, airspaceType: AirMapAirspaceType)
}

// Default implementations making protocol conformance optional
extension MGLMapViewDelegate {
	
	public func airMapMapViewJurisdictionsDidChange(mapView: AirMapMapView, jurisdictions: [AirMapJurisdiction]) {}
	public func airMapMapViewRegionDidChange(mapView: AirMapMapView, jurisdictions: [AirMapJurisdiction], activeRulesets: [AirMapRuleset]) {}
	public func airMapMapViewDidAddAirspaceType(mapView: AirMapMapView, ruleset: AirMapRuleset, airspaceType: AirMapAirspaceType, layer: inout MGLStyleLayer) {}
	public func airMapMapViewDidRemoveAirspaceType(mapView: AirMapMapView, airspaceType: AirMapAirspaceType) {}
}
