//
//  Rx+AirMap.swift
//  AirMap
//
//  Created by Adolfo Martinelli on 7/11/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift

extension ObservableType {
	
	public func mapToVoid() -> Observable<Void> {
		return self.map { _ -> Void in
			return ()
		}
	}
	
	public func asOptional() -> Observable<E?> {
		return self.map {
			Optional.Some($0)
		}
	}
	
}
