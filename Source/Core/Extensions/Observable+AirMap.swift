//
//  ObservableType+SDK.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/26/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift

extension Observable {
	
	func subscribe(_ result: @escaping (Result<Element>) -> Void) {
		
		self
			.subscribe(
				onNext:  { result(Result<Element>.value($0)) },
				onError: { error in result(Result<Element>.error(error)) }
			)
			.addDisposableTo(AirMap.disposeBag)
	}

}
