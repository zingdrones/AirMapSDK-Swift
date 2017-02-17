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
	func tabSelectorDidSelectItemAtIndex(_ index: Int)
}

class TabSelectorView: UIView {
	
	var items: [String] = [] {
		didSet { setupView() }
	}
	weak var delegate: TabSelectorDelegate?
	
	fileprivate var buttons = [UIButton]()
	fileprivate let disposeBag = DisposeBag()
	
	fileprivate func setupView() {
		
		buttons.forEach { $0.removeFromSuperview() }
		
		buttons = items.enumerated().map { (index: Int, item) in
			
			let button = UIButton()
			button.setTitle(item, for: UIControlState())
			button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
			button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .highlighted)
			button.titleEdgeInsets = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
			button.rx.controlEvent(UIControlEvents.touchUpInside)
				.subscribe(onNext: { [weak self] _ in
					self?.delegate?.tabSelectorDidSelectItemAtIndex(index)
				})
				.disposed(by: disposeBag)
			return button
		}
		
		buttons.forEach { button in addSubview(button) }
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		for (index, button) in buttons.enumerated() {
			button.frame = bounds
			button.frame.size.width = bounds.width / CGFloat(buttons.count)
			button.frame.origin.x = button.frame.width * CGFloat(index)
			button.frame = button.frame.integral
		}
	}

}
