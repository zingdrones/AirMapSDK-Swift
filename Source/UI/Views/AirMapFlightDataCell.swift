//
//  AirMapFlightDataCell.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/18/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AirMapFlightDataCell: UITableViewCell {
	
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var slider: UISlider!
	@IBOutlet weak var value: UILabel!
	
	var model: FlightPlanDataTableRow<Double>! {
		didSet { setupBindings() }
	}

	fileprivate let disposeBag = DisposeBag()
		
	fileprivate func setupBindings() {
		
		model.title
			.asObservable()
			.bindTo(label.rx.text)
			.addDisposableTo(disposeBag)
		
		slider.rx.value
			.map(unowned(self, AirMapFlightDataCell.sliderValueToPreset))
			.map { $0.value}
			.bindTo(model.value)
			.addDisposableTo(disposeBag)
		
		slider.rx.value
			.map(unowned(self, AirMapFlightDataCell.sliderValueToPreset))
			.map { $0.title }
			.bindTo(value.rx.text)
			.addDisposableTo(disposeBag)
	}
	
	fileprivate func sliderValueToPreset(_ value: Float) -> (title: String, value: Double) {
		let presets = model.values!
		let maxIndex = presets.count - 1
		let index = Int(round(Double(maxIndex) * Double(value)))
		return presets[index]
	}
	
	fileprivate func modelValueToSliderValue(_ value: Double) -> Float {
		return min(Float(value/model.values!.last!.value), 1)
	}
	
}
