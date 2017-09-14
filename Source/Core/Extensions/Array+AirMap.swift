//
//  Array+AirMap.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 5/3/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

public extension Array where Element: Equatable {
	
	public mutating func removeObject(_ object: Element) {
		if let index = self.index(of: object) {
			self.remove(at: index)
		}
	}
	
	public mutating func removeObjectsInArray(_ array: [Element]) {
		for object in array {
			self.removeObject(object)
		}
	}
}

extension Sequence {
	
	#if swift(>=3.2)
	public typealias SequenceElement = Element
	#else
	public typealias SequenceElement = Iterator.Element
	#endif

	public func grouped<T: Hashable>(by criteria: (SequenceElement) -> T) -> [T: [SequenceElement]] {
		var groups: [T: [SequenceElement]] = [:]
		for element in self {
			let key = criteria(element)
			if groups.keys.contains(key) {
				groups[key]!.append(element)
			} else {
				groups[key] = [element]
			}
		}
		return groups
	}
}
