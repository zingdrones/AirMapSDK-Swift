//
//  AirMapFlightDataDateCell.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/18/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class AirMapFlightDataDateCell: UITableViewCell {

	fileprivate static let dateFormatter: DateFormatter = {
		$0.doesRelativeDateFormatting = true
		$0.dateStyle = .medium
		$0.timeStyle = .short
		return $0
	}(DateFormatter())
	
	@IBOutlet weak var date: UITextField!
	
	var model: FlightPlanDataTableRow<Date?>! {
		didSet { setupBindings() }
	}
	
	fileprivate let disposeBag = DisposeBag()
	fileprivate let datePicker = UIDatePicker()
	fileprivate let doneButton = UIButton()
	
	override var canBecomeFirstResponder : Bool {
		return true
	}
	
	override var inputView: UIView? {
		return datePicker
	}
	
	override var inputAccessoryView: UIView? {
		return doneButton
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		setupInputViews()
	}
	
	fileprivate func setupInputViews() {
		
		doneButton.setTitle("DONE", for: UIControlState())
		doneButton.backgroundColor = .airMapDarkGray
		datePicker.minimumDate = Date()
		doneButton.addTarget(self, action: #selector(dismissPicker), for: .touchUpInside)
	}
	
	@objc fileprivate func dismissPicker() {
		endEditing(true)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		doneButton.frame.size = frame.size
		doneButton.frame.size.height = 44
	}

	fileprivate func setupBindings() {
		
		model.value.asObservable()
			.map { date in
				return date == nil ? "Now" : AirMapFlightDataDateCell.dateFormatter.string(from: date!)
			}
			.bindTo(date.rx.text)
			.disposed(by: disposeBag)
		
		datePicker.rx.date.asDriver()
			.skip(1)
			.map { .some($0) }
			.drive(model.value)
			.disposed(by: disposeBag)
	}
}
