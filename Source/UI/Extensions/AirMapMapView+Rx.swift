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
import RxSwiftExt

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
	
	public var mapDidFinishRenderingMap: Observable<(mapView: Base, fullyRendered: Bool)> {
		return delegate.methodInvoked(#selector(MGLMapViewDelegate.mapViewDidFinishRenderingMap(_:fullyRendered:)))
			.map { ($0[0] as! Base, $0[1] as! Bool) }
	}
	
	public var mapDidFinishRenderingFrame: Observable<(mapView: Base, fullyRendered: Bool)> {
		return delegate.methodInvoked(#selector(MGLMapViewDelegate.mapViewDidFinishRenderingFrame(_:fullyRendered:)))
			.map { ($0[0] as! Base, $0[1] as! Bool) }
	}

	public var mapDidFinishLoadingMap: Observable<Base> {
		return delegate.methodInvoked(#selector(MGLMapViewDelegate.mapViewDidFinishLoadingMap(_:)))
			.map { $0[0] as! Base }
	}
	
	public var mapDidFailLoadingMap: Observable<(mapView: Base, error: Error)> {
		return delegate.methodInvoked(#selector(MGLMapViewDelegate.mapViewDidFailLoadingMap(_:withError:)))
			.map { ($0[0] as! Base, $0[1] as! Error) }
	}
	
	public var mapDidFinishLoadingStyle: Observable<(mapView: Base, style: MGLStyle)> {
		let observable = delegate.methodInvoked(#selector(MGLMapViewDelegate.mapView(_:didFinishLoading:)))
			.map { (mapView: $0[0] as! Base, style: $0[1] as! MGLStyle) }
		if let style = base.style {
			return observable.startWith((base, style))
		} else {
			return observable
		}
	}

	public var mapDidStartLoading: Observable<Base> {
		return delegate.methodInvoked(#selector(MGLMapViewDelegate.mapViewWillStartLoadingMap(_:)))
			.map { $0[0] as! Base }
	}
	
	public var mapDidFinishLoading: Observable<Base> {
		return delegate.methodInvoked(#selector(MGLMapViewDelegate.mapViewDidFinishLoadingMap(_:)))
			.map { $0[0] as! Base }
	}
	
	public var jurisdictions: Observable<[AirMapJurisdiction]> {
		return mapDidFinishLoadingStyle
			.flatMapLatest({ (style) -> Observable<[AirMapJurisdiction]> in
				return Observable
					.merge(
						self.regionIsChanging
							.throttle(3, latest: true, scheduler: MainScheduler.instance),
						self.regionDidChangeAnimated.map({$0.mapView})
							.throttle(1, latest: true, scheduler: MainScheduler.instance),
						self.mapDidFinishRenderingMap.map({$0.mapView})
					)
					.map({ $0.jurisdictions })
					.distinctUntilChanged(==)
			})
	}
	
}
