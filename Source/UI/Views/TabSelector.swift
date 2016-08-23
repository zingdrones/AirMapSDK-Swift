//
//  TabSelectorView.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/28/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa

protocol TabSelectorDelegate: class {
	func tabSelectorDidSelectItemAtIndex(index: Int)
}

class TabSelectorView: UIView {
	
	var items: [String] = [] {
		didSet { setupView() }
	}
	weak var delegate: TabSelectorDelegate
	
	private var buttons = [UIButton]()
	private let disposeBag = DisposeBag()
	
	private func setupView() {
		
		buttons.forEach { $0.removeFromSuperview() }
		
		buttons = items.enumerate().map { index, item in
			
			let button = UIButton()
			button.setTitle(item, forState: .Normal)
			button.titleLabel?.font = UIFont.boldSystemFontOfSize(15)
			button.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
			button.titleEdgeInsets = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
			button.rx_controlEvent(UIControlEvents.TouchUpInside)
				.subscribeNext { [weak self] _ in self?.delegate?.tabSelectorDidSelectItemAtIndex(index) }
				.addDisposableTo(disposeBag)
			return button
		}
		
		buttons.forEach { addSubview($0) }
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		for (index, button) in buttons.enumerate() {
			button.frame = bounds
			button.frame.size.width = bounds.width / CGFloat(buttons.count)
			button.frame.origin.x = button.frame.width * CGFloat(index)
			button.frame = CGRectIntegral(button.frame)
		}
	}

}
