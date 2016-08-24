//
//  AirMapPhoneVerificationViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/8/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa
import libPhoneNumber_iOS

class AirMapPhoneVerificationViewController: UITableViewController {
	
	// MARK: - Properties
	
	var pilot: AirMapPilot!
	
	@IBOutlet weak var submitButton: UIButton!
	@IBOutlet weak var country: UILabel!
	@IBOutlet weak var phone: UITextField!
	
	private var countryCode: String!
	private let phoneUtil = NBPhoneNumberUtil()
	private let activityIndicator = ActivityIndicator()

	private var phoneNumber: NBPhoneNumber? {
		guard let phone =  phone.text, let region = countryCode else { return nil }
		return try? phoneUtil.parse(phone, defaultRegion: region)
	}
	
	private var numberFormatter = NBAsYouTypeFormatter()
	private let disposeBag = DisposeBag()
	
	// MARK: - View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupDefaultCountryCode()
		setupPhoneNumberField()
		setupBindings()
		
		phone.text = numberFormatter.inputString(pilot.phone)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		validateForm()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		phone.becomeFirstResponder()
	}
	
	override var inputAccessoryView: UIView? {
		return submitButton
	}
	
	override func canBecomeFirstResponder() -> Bool {
		return true
	}
	
	private enum Segue: String {
		case pushSelectCountry
		case pushVerifySMS
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		guard let identifier = segue.identifier else { return }
		
		switch Segue(rawValue: identifier)! {

		case .pushSelectCountry:
			let countryVC = segue.destinationViewController as! AirMapPhoneCountryViewController
			countryVC.selectionDelegate = self
			countryVC.selectedCountryIdentifier = countryCode
			countryVC.locale = AirMapLocale.currentLocale()
		
		case .pushVerifySMS:
			break
		}
	}
	
	// MARK: - Setup

	private func setupBindings() {
		
		phone.rx_text.asObservable()
			.map { [unowned self] text in
				guard let phoneNumber = self.phoneNumber else { return false }
				return self.phoneUtil.isValidNumberForRegion(phoneNumber, regionCode: self.countryCode)
			}
			.bindTo(submitButton.rx_enabled)
			.addDisposableTo(disposeBag)
		
		activityIndicator.asObservable()
			.throttle(0.25, scheduler: MainScheduler.instance)
			.distinctUntilChanged()
			.bindTo(rx_loading)
			.addDisposableTo(disposeBag)
	}
	
	private func setupDefaultCountryCode() {
		countryCode = AirMapLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String ?? "US"
	}
	
	private func setupPhoneNumberField() {
		let samplePhoneNumber = try? phoneUtil.getExampleNumberForType(countryCode, type: .MOBILE)
		let samplePhoneString = try? phoneUtil.format(samplePhoneNumber, numberFormat: .INTERNATIONAL)
		phone.placeholder =  samplePhoneString
		numberFormatter = NBAsYouTypeFormatter(regionCode: countryCode)
	}
	
	// MARK: - Instance Methods

	@IBAction func submitForm() {

		guard
			let phoneNumber = phoneNumber,
			let e164 = try? phoneUtil.format(phoneNumber, numberFormat: .E164) else { return }

		pilot.phone = e164
		
		AirMap.rx_updatePilot(pilot)
			.trackActivity(activityIndicator)
			.flatMap { [unowned self] _ in
				AirMap.rx_sendVerificationToken().trackActivity(self.activityIndicator)
			}
			.doOnCompleted(unowned(self, AirMapPhoneVerificationViewController.verifySMSToken))
			.subscribe()
			.addDisposableTo(disposeBag)
	}
	
	private func validateForm() {
		submitButton?.enabled = phoneUtil.isValidNumberForRegion(phoneNumber, regionCode: countryCode) ?? false
	}
	
	private func verifySMSToken() {
		performSegueWithIdentifier(Segue.pushVerifySMS.rawValue, sender: self)
	}
		
	@IBAction func dismiss(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
}

// MARK: - Extensions

extension AirMapPhoneVerificationViewController: AirMapPhoneCountrySelectorDelegate {
	
	func phoneCountrySelectorDidSelect(country name: String, country code: String) {
		if countryCode != code { phone.text = nil }
		countryCode = code
		country.text = name
		setupPhoneNumberField()
		navigationController?.popViewControllerAnimated(true)
	}
	
	func phoneCountrySelectorDidCancel() {
		navigationController?.popViewControllerAnimated(true)
	}
	
}

extension AirMapPhoneVerificationViewController: UITextFieldDelegate {
	
	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		
		let newString = (textField.text ?? "" as NSString)
			.stringByReplacingCharactersInRange(range, withString: string)
		
		var shouldChange = false
		
		if string.characters.count + range.location < 20 {
			
			if range.length == 0 {
				phone.text = numberFormatter.inputDigit(string)
			} else if range.length == 1 {
				phone.text = numberFormatter.removeLastDigit()
			} else if string.characters.count > 1 {
				shouldChange = false
			} else {
				numberFormatter.inputString(newString)
				shouldChange = true
			}
		}
		
		validateForm()
		return shouldChange
	}
	
}
