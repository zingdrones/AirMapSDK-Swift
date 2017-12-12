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
	
	public func then(onNext: ((E) throws -> Void)? = nil, onError: ((Swift.Error) throws -> Void)? = nil, onCompleted: (() throws -> Void)? = nil, onSubscribe: (() -> ())? = nil, onSubscribed: (() -> ())? = nil, onDispose: (() -> ())? = nil)
		-> Observable<E> {
			return `do`(onNext: onNext, onError: onError, onCompleted: onCompleted, onSubscribe: onSubscribe, onSubscribed: onSubscribed, onDispose: onDispose)
	}
	
	func thenSubscribe(_ result: @escaping (Result<E>) -> Void) {
		
		self
			.subscribe(
				onNext:  { result(Result<E>.value($0)) },
				onError: {
					let error = $0 as? AirMapError ?? AirMapError.unknown(underlying: $0)
					result(Result<E>.error(error))
			})
			.disposed(by: AirMap.disposeBag)
	}
	
	public func repeatLatest(interval: RxTimeInterval, scheduler: SchedulerType) -> Observable<E> {
		
		return flatMapLatest {
			Observable<Int>
				.timer(0, period: interval, scheduler: scheduler)
				.map(to: $0)
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
