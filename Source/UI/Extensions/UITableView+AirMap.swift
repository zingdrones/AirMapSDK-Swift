//
//  UITableView+AirMap.swift
//  AirMap
//
//  Created by Adolfo Martinelli on 7/9/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit

protocol Dequeueable {
	static var reuseIdentifier: String { get }
}

extension Dequeueable {
	static var reuseIdentifier: String {
		return String(describing: Self.self)
	}
}

protocol ObjectAssignable {
	associatedtype ObjectType
	func setObject(_ object: ObjectType?)
}

extension UITableView {
	
	func dequeueCell<T: Dequeueable>(at indexPath: IndexPath) -> T {
		return self.dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
	}
	
	func cellWith
		<T: ObjectAssignable>
		(_ object: T.ObjectType?, at indexPath: IndexPath) -> T where T: Dequeueable, T: UITableViewCell {
		
		let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
		cell.setObject(object)
		return cell
	}
	
	func cellWith
		<T: ObjectAssignable>
		(_ object: T.ObjectType, at indexPath: IndexPath, withIdentifier: String) -> T where T: Dequeueable, T: UITableViewCell {
		
		let cell = dequeueReusableCell(withIdentifier: withIdentifier, for: indexPath) as! T
		cell.setObject(object)
		return cell
	}
	
	func deselectSelectedRows(_ animated: Bool) {
		for indexPath in indexPathsForSelectedRows ?? [] {
			deselectRow(at: indexPath, animated: animated)
		}
	}

	/// calculate and update tableview's header height using auto layout
	func layoutAndResizeHeader() {
		if let header = tableHeaderView {			
			header.setNeedsLayout()
			header.layoutIfNeeded()
			var frame = header.frame
			frame.size.height = header.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
			header.frame = frame
			tableHeaderView = header
		}
	}

}
