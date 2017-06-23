//
//  Rx+AirMap.swift
//  AirMap
//
//  Created by Adolfo Martinelli on 7/11/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa

extension ObservableType {
	
	public func mapToVoid() -> Observable<Void> {
		return self.map { _ -> Void in }
	}

	public func asOptional() -> Observable<E?> {
		return self.map {
			Optional.some($0)
		}
	}
	
}

extension Observable where Element: Equatable {
	
	public func filter(_ value: E) -> Observable<E> {
		return filter { $0 == value }
	}
}

extension SharedSequence {
	
	public func mapToVoid() -> SharedSequence<S, Void> {
		return map { _ in Void() }
	}
}
