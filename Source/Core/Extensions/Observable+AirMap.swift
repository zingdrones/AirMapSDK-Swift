//
//  ObservableType+SDK.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/26/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift

extension Observable {
	
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
