//
//  Rx+AirMap.swift
//  AirMap
//
//  Created by Adolfo Martinelli on 7/11/16.
//  Copyright 2018 AirMap, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import RxSwift
import RxCocoa

extension ObservableType {
	
	public func mapToVoid() -> Observable<Void> {
		return self.map { _ -> Void in }
	}

	public func asOptional() -> Observable<Element?> {
		return self.map {
			Optional.some($0)
		}
	}
	
	public func then(onNext: ((Element) throws -> Void)? = nil, onError: ((Swift.Error) throws -> Void)? = nil, onCompleted: (() throws -> Void)? = nil, onSubscribe: (() -> ())? = nil, onSubscribed: (() -> ())? = nil, onDispose: (() -> ())? = nil)
		-> Observable<Element> {
			return `do`(onNext: onNext, onError: onError, onCompleted: onCompleted, onSubscribe: onSubscribe, onSubscribed: onSubscribed, onDispose: onDispose)
	}
	
	func thenSubscribe(_ result: @escaping (Result<Element>) -> Void) {
		
		self
			.subscribe(
				onNext:  { result(Result<Element>.value($0)) },
				onError: {
					let error = $0 as? AirMapError ?? AirMapError.unknown(underlying: $0)
					result(Result<Element>.error(error))
			})
			.disposed(by: AirMap.disposeBag)
	}	
}

extension Observable where Element: Equatable {
	
	public func filter(_ value: Element) -> Observable<Element> {
		return filter { $0 == value }
	}
}

extension SharedSequence {
	
	public func mapToVoid() -> SharedSequence<SharingStrategy, Void> {
		return map { _ in Void() }
	}
}
