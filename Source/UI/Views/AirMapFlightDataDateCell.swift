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

	private static let dateFormatter: NSDateFormatter = {
		$0.doesRelativeDateFormatting = true
		$0.dateStyle = .MediumStyle
		$0.timeStyle = .ShortStyle
		return $0
	}(NSDateFormatter())
	
	@IBOutlet weak var date: UITextField!
	
	var model: FlightPlanDataTableRow<NSDate?>! {
		didSet { setupBindings() }
	}
	
	private let disposeBag = DisposeBag()
	private let datePicker = UIDatePicker()
	private let doneButton = UIButton()
	
	override func canBecomeFirstResponder() -> Bool {
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
	
	private func setupInputViews() {
		
		doneButton.setTitle("DONE", forState: .Normal)
		doneButton.backgroundColor = .airMapGray()
		datePicker.minimumDate = NSDate()
		doneButton.addTarget(self, action: #selector(dismissPicker), forControlEvents: .TouchUpInside)
	}
	
	@objc private func dismissPicker() {
		endEditing(true)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		doneButton.frame.size = frame.size
		doneButton.frame.size.height = 44
	}

	private func setupBindings() {
		
		model.value.asObservable()
			.map { date in
				return date == nil ? "Now" : AirMapFlightDataDateCell.dateFormatter.stringFromDate(date!)
			}
			.bindTo(date.rx_text)
			.addDisposableTo(disposeBag)
		
		datePicker.rx_date.asDriver()
			.skip(1)
			.map { .Some($0) }
			.drive(model.value)
			.addDisposableTo(disposeBag)
	}
}