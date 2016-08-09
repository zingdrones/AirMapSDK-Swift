//
//  ObservableType+SDK.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/26/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift

extension ObservableType {
	
	func subscribe<T>(handler: (result: T?, error: NSError?) -> Void) {
		
		return subscribe(
			onNext:  { handler(result: $0 as? T, error: nil) },
			onError: { handler(result: nil, error: $0 as NSError) }
			).addDisposableTo(AirMap.disposeBag)
	}
	
	func subscribe(handler: (error: NSError?) -> Void) {
		
		return subscribe(
			onNext:  { _ in handler(error: nil) },
			onError: { handler(error: $0 as NSError) }
			).addDisposableTo(AirMap.disposeBag)
	}
	
}
