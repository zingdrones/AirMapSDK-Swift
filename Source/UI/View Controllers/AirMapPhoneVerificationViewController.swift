//
//  AirMapPhoneVerificationViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/8/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import libPhoneNumber_iOS
import RxSwift
import RxCocoa

class AirMapPhoneVerificationViewController: UITableViewController, AirMapPhoneCountrySelectorDelegate, UITextFieldDelegate {
	
	// MARK: - Properties
	
	var pilot: AirMapPilot!
	
	@IBOutlet weak var submitButton: UIButton!
	@IBOutlet weak var country: UILabel!
	@IBOutlet weak var phone: UITextField!
	
	private var countryCode: String!
	private var phoneUtil = NBPhoneNumberUtil()

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
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
		guard let identifier = segue.identifier else { return }
		
		switch identifier {
			
		case "pushSelectCountry":
			let countryVC = segue.destinationViewController as! AirMapPhoneCountryViewController
			countryVC.selectionDelegate = self
			countryVC.selectedCountryIdentifier = countryCode
			countryVC.locale = currentLocale()
			
		case "pushVerificationCode":
			break
//			let verifySMSVC = segue.destinationViewController as! VerifySMSViewController
//			verifySMSVC.phoneNumberVerification = phoneNumberVerification
			
		default:
			break
		}
	}
	
	// MARK: - Instance Methods
	
	func setupBindings() {
		
		phone.rx_text.asObservable()
			.map { [unowned self] text in
				guard let phoneNumber = self.phoneNumber else { return false }
				return self.phoneUtil.isValidNumberForRegion(phoneNumber, regionCode: self.countryCode)
			}
			.bindTo(submitButton.rx_enabled)
			.addDisposableTo(disposeBag)
	}
	
	func setupDefaultCountryCode() {
		countryCode = currentLocale().objectForKey(NSLocaleCountryCode) as? String ?? "US"
	}
	
	private func placeholder() -> String {
		let samplePhoneNumber = try? phoneUtil.getExampleNumberForType(countryCode, type: .MOBILE)
		let samplePhoneString = try? phoneUtil.format(samplePhoneNumber, numberFormat: NBEPhoneNumberFormat.NATIONAL)
		return samplePhoneString ?? ""
	}
	
	func setupPhoneNumberField() {
		phone.placeholder =  placeholder()
		numberFormatter = NBAsYouTypeFormatter(regionCode: countryCode)
	}
	
	func validateForm() {
		submitButton?.enabled = phoneUtil.isValidNumberForRegion(phoneNumber, regionCode: countryCode) ?? false
	}
	
	@IBAction func submitForm() {

		guard
			let phoneNumber = phoneNumber,
			let e164 = try? phoneUtil.format(phoneNumber, numberFormat: .E164) else { return }

		let p = AirMapPilot { pilot in
			pilot.pilotId = self.pilot.pilotId
			pilot.phone = e164
		}
		
		AirMap.rx_updatePilot(p)
			.doOnCompleted { [weak self] _ in
				self?.pilot.phone = e164
			}
			.subscribe()
			.addDisposableTo(disposeBag)
	}
	
	func currentLocale() -> NSLocale {
		
		// Workaround for bug in simulator
		#if (arch(i386) || arch(x86_64)) && os(iOS)
			let currentLocale = NSLocale(localeIdentifier: "en_US")
		#else
			let currentLocale = NSLocale.currentLocale()
		#endif
		
		return currentLocale
	}
	
	@IBAction func dismiss(sender: AnyObject) {
		
		dismissViewControllerAnimated(true, completion: nil)
	}
		
	// MARK: - PhoneCountrySelectorDelegate
	
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
	
	// MARK: - UITextFieldDelegate
	
	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		
		let newString = (NSString(string: textField.text!)).stringByReplacingCharactersInRange(range, withString: string)
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
