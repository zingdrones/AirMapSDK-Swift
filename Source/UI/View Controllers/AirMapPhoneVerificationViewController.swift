//
//  AirMapPhoneVerificationViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/8/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa
import PhoneNumberKit
import libPhoneNumber_iOS

class AirMapPhoneVerificationViewController: UITableViewController, AnalyticsTrackable {
	
	// MARK: - Properties
	
	var screenName = "Phone Verification - Phone Number"
	
	var pilot: AirMapPilot!
	
	@IBOutlet weak var submitButton: UIButton!
	@IBOutlet weak var country: UILabel!
	@IBOutlet weak var phone: PhoneNumberTextField!
	
	private var countryCode: String!
	private let phoneUtil = NBPhoneNumberUtil()
	private let activityIndicator = ActivityIndicator()

	private var phoneNumber: PhoneNumber? {
		guard let phone =  phone.text, let region = countryCode else { return nil }
		return try? PhoneNumber(rawNumber:phone, region: region)
	}
	
	private let disposeBag = DisposeBag()
	
	// MARK: - View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupDefaultCountryCode()
		setupPhoneNumberField()
		setupBindings()
		
		if let p = pilot.phone {
			print(PartialFormatter().formatPartial(p))
			phone.text = PartialFormatter().formatPartial(p)
		}
		
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		validateForm()
		trackView()
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
			trackEvent(.tap, label: "Select Country")
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
				return phoneNumber.isValidNumber
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
		countryCode = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String ?? "US"
		country.text = NSLocale.currentLocale().displayNameForKey(NSLocaleCountryCode, value: countryCode) ?? "United States"
		phone?.defaultRegion = countryCode
	}
	
	private func setupPhoneNumberField() {
		
		let samplePhoneNumber = try? phoneUtil.getExampleNumberForType(countryCode, type: .MOBILE)
		let samplePhoneString = try? phoneUtil.format(samplePhoneNumber, numberFormat: .INTERNATIONAL)
		phone?.placeholder =  samplePhoneString
		phone?.defaultRegion = countryCode
	}
	
	// MARK: - Instance Methods

	@IBAction func submitForm() {

		guard let phoneNumber = phoneNumber else { return }
		
		trackEvent(.tap, label: "Save Button")

		pilot.phone = phoneNumber.toE164()
		
		AirMap.rx_updatePilot(pilot)
			.trackActivity(activityIndicator)
			.flatMap { [unowned self] _ in
				AirMap.rx_sendVerificationToken()
					.trackActivity(self.activityIndicator)
					.doOnError { [unowned self] error in
						self.trackEvent(.save, label: "error", value: (error as NSError).code)
					}
					.doOnCompleted { [unowned self] _ in
						self.trackEvent(.save, label: "Success")
					}
			}
			.doOnCompleted(unowned(self, AirMapPhoneVerificationViewController.verifySMSToken))
			.subscribe()
			.addDisposableTo(disposeBag)
	}
	
	private func validateForm() {
		submitButton?.enabled = phone.isValidNumber ?? false
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
		if countryCode != code { phone.text = PartialFormatter().formatPartial(phone.text ?? "") }
		
		countryCode = code
		country.text = name
		setupPhoneNumberField()
		navigationController?.popViewControllerAnimated(true)
	}
	
	func phoneCountrySelectorDidCancel() {
		navigationController?.popViewControllerAnimated(true)
	}
	
}
