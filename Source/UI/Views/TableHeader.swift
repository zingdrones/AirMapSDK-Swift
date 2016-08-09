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
		self.init(frame: CGRectMake(0, 0, 50, 50))

		backgroundColor = .clearColor()
		textLabel.textColor = .airMapGray()
		textLabel.font = UIFont.boldSystemFontOfSize(15)
		textLabel.text = title
		addSubview(textLabel)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		textLabel.frame = CGRectInset(bounds, 15, 0)
	}
}
