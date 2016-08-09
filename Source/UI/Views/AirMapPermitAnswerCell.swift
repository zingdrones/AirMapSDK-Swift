//
//  AirMapPermitAnswerCell.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/20/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class AirMapPermitAnswerCell: UITableViewCell {
	
	@IBOutlet weak var answerLabel: UILabel!
	@IBOutlet weak var selectionIndicator: UIImageView!
	
	var answer: Variable<AirMapAvailablePermitAnswer>! {
		didSet { setupBindings() }
	}
	
	private let disposeBag = DisposeBag()
	
	private func setupBindings() {
		answer
			.asObservable()
			.map { $0.text }
			.bindTo(answerLabel.rx_text)
			.addDisposableTo(disposeBag)
	}
	
	override var selected: Bool {
		didSet {
			selectionIndicator.highlighted = selected
		}
	}	
	
}