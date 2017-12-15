//
//  MGLMapView+Rx.swift
//  AirMap
//
//  Created by Adolfo Martinelli on 1/24/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Mapbox
import RxSwift
import RxCocoa

extension AirMapMapView: HasDelegate {
	public typealias Delegate = MGLMapViewDelegate
}

public class RxMGLMapViewDelegateProxy: DelegateProxy<AirMapMapView, MGLMapViewDelegate>, DelegateProxyType, MGLMapViewDelegate {

	public weak private(set) var mapView: AirMapMapView?

	public init(mapView: AirMapMapView) {
		self.mapView = mapView
		super.init(parentObject: mapView, delegateProxy: RxMGLMapViewDelegateProxy.self)
	}

	public static func registerKnownImplementations() {
		register(make: RxMGLMapViewDelegateProxy.init)
	}
	
	deinit {
		
	}
}

extension Reactive where Base: AirMapMapView {
    
	public var delegate: DelegateProxy<AirMapMapView, MGLMapViewDelegate> {
		return RxMGLMapViewDelegateProxy.proxy(for: base)
	}
	
	public var regionWillChangeAnimated: Observable<(mapView: Base, animated: Bool)> {		
		return delegate.methodInvoked(#selector(MGLMapViewDelegate.mapView(_:regionWillChangeAnimated:)))
			.map { ($0[0] as! Base, $0[1] as! Bool) }
	}
	
	public var regionIsChanging: Observable<Base> {
		return delegate.methodInvoked(#selector(MGLMapViewDelegate.mapViewRegionIsChanging(_:)))
			.map { $0.first as! Base }
	}
	
	public var regionDidChangeAnimated: Observable<(mapView: Base, animated: Bool)> {
        return delegate.methodInvoked(#selector(MGLMapViewDelegate.mapView(_:regionDidChangeAnimated:)))
            .map { ($0[0] as! Base, $0[1] as! Bool) }
	}
	
	public var mapDidFinishLoadingTiles: Observable<(mapView: Base, fullyRendered: Bool)> {
		return delegate.methodInvoked(#selector(MGLMapViewDelegate.mapViewDidFinishRenderingMap(_:fullyRendered:)))
			.map { ($0[0] as! Base, $0[1] as! Bool) }
	}
	
	public var mapDidFinishLoadingStyle: Observable<(mapView: Base, style: MGLStyle)> {
		return delegate.methodInvoked(#selector(MGLMapViewDelegate.mapView(_:didFinishLoading:)))
			.map { ($0[0] as! Base, $0[1] as! MGLStyle) }
	}
	
	public var mapDidStartLoading: Observable<Base> {
		return delegate.methodInvoked(#selector(MGLMapViewDelegate.mapViewWillStartLoadingMap(_:)))
			.map { $0.first as! Base }
	}
	
	public var mapDidFinishLoading: Observable<Base> {
		return delegate.methodInvoked(#selector(MGLMapViewDelegate.mapViewDidFinishLoadingMap(_:)))
			.map { $0.first as! Base }
	}
	
}
