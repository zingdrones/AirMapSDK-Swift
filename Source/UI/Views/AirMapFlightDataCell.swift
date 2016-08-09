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

	private let disposeBag = DisposeBag()
		
	private func setupBindings() {
		
		model.value
			.asObservable()
			.single()
			.map(unowned(self, AirMapFlightDataCell.modelValueToSliderValue))
			.bindTo(slider.rx_value)
			.addDisposableTo(disposeBag)
		
		model.title
			.asObservable()
			.bindTo(label.rx_text)
			.addDisposableTo(disposeBag)
		
		slider.rx_value
			.map(unowned(self, AirMapFlightDataCell.sliderValueToPreset))
			.map { $0.value}
			.bindTo(model.value)
			.addDisposableTo(disposeBag)
		
		slider.rx_value
			.map(unowned(self, AirMapFlightDataCell.sliderValueToPreset))
			.map { $0.title }
			.bindTo(value.rx_text)
			.addDisposableTo(disposeBag)
	}
	
	private func sliderValueToPreset(value: Float) -> (title: String, value: Double) {
		let presets = model.values!
		let maxIndex = presets.count - 1
		let index = Int(round(Double(maxIndex) * Double(value)))
		return presets[index]
	}
	
	private func modelValueToSliderValue(value: Double) -> Float {
		return min(Float(value/model.values!.last!.value), 1)
	}
	
}