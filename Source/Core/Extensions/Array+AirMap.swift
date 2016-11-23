//
//  Array+AirMap.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 5/3/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

extension Array where Element: Equatable {
	
	mutating func removeObject(object: Element) {
		if let index = self.indexOf(object) {
			self.removeAtIndex(index)
		}
	}
	
	mutating func removeObjectsInArray(array: [Element]) {
		for object in array {
			self.removeObject(object)
		}
	}
    
    
    func filterDuplicates(@noescape includeElement: (lhs:Element, rhs:Element) -> Bool) -> [Element]{
        var results = [Element]()
        
        forEach { (element) in
            let existingElements = results.filter {
                return includeElement(lhs: element, rhs: $0)
            }
            if existingElements.count == 0 {
                results.append(element)
            }
        }
        
        return results
    }}
