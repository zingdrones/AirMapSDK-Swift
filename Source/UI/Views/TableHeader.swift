//
//  TableHeader.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/19/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

class TableHeader: UIView {
	
	let textLabel = UILabel()

	convenience init?(_ title: String?) {
		guard let title = title else {
			return nil
		}
		self.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))

		backgroundColor = .clear
		textLabel.textColor = .airMapDarkGray
		textLabel.font = UIFont.boldSystemFont(ofSize: 15)
		textLabel.text = title
		addSubview(textLabel)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		textLabel.frame = bounds.insetBy(dx: 15, dy: 0)
	}
}
