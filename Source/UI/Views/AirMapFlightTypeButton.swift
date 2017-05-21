//
//  AirMapFlightTypeButton.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/9/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit

class AirMapFlightTypeButton: UIButton {
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		adjustInsets()
	}
	
	// center align the text label below the image
	
	fileprivate func adjustInsets() {
		
		let spacing: CGFloat = 3.0
		
		var titleEdgeInsets = UIEdgeInsets.zero
		if let image = imageView?.image {
			titleEdgeInsets.left = -image.size.width
			titleEdgeInsets.bottom = -(image.size.height + spacing)
		}
		self.titleEdgeInsets = titleEdgeInsets;
		
		var imageEdgeInsets = UIEdgeInsets.zero
		if let
			text: NSString = self.titleLabel?.text as NSString?,
			let font = self.titleLabel?.font {
				let attributes = [NSFontAttributeName: font]
				let titleSize = text.size(attributes: attributes)
				imageEdgeInsets.top = -(titleSize.height + spacing)
				imageEdgeInsets.right = -titleSize.width
			}
		self.imageEdgeInsets = imageEdgeInsets
	}
	
}
