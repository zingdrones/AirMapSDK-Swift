//
//  AirMapVerifySMSCodeViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/8/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class AirMapVerifySMSCodeViewController: UITableViewController, AnalyticsTrackable {
	
	var screenName = "Phone Verification - SMS Code"
	
	@IBOutlet var submitButton: UIButton!
	@IBOutlet weak var smsCode: UITextField!
	@IBOutlet weak var smsTextField: UITextField!
	
	var phoneNumber:String?
	
	fileprivate let disposeBag = DisposeBag()
	fileprivate let activityIndicator = ActivityTracker()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupBindings()
		smsCode.becomeFirstResponder()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		trackView()
	}
	
	override var canBecomeFirstResponder : Bool {
		
		return true
	}
	
	override var inputAccessoryView: UIView? {
		
		return submitButton
	}
	
	fileprivate func setupBindings() {
		
		smsTextField.rx.text.asObservable()
			.map { $0?.count == Constants.AirMapApi.smsCodeLength }
			.bind(to: submitButton.rx.isEnabled)
			.disposed(by: disposeBag)
		
		activityIndicator.asObservable()
			.throttle(0.25, scheduler: MainScheduler.instance)
			.distinctUntilChanged()
			.bind(to: rx_loading)
			.disposed(by: disposeBag)
	}
	
	@IBAction func submitSMSCode() {
		
		trackEvent(.tap, label: "Submit Button")
		smsCode.resignFirstResponder()
		
		AirMap.rx.verifySMS(smsTextField.text!)
			.trackActivity(activityIndicator)
			.map { $0.verified}
			.subscribe (
				onNext: (unowned(self, AirMapVerifySMSCodeViewController.didVerifyPhoneNumber)),
				onError: { [unowned self] error in
					self.trackEvent(.save, label: "Error", value: NSNumber(value: (error as NSError).code))
					if let error = error as? AirMapError {
						self.displayErrorAlert(message: error.description)
					} else {
						self.displayErrorAlert(message: error.localizedDescription)
					}
				},
				onCompleted: { [unowned self] _ in
					self.trackEvent(.save, label: "Success")
				}
			)
			.disposed(by: disposeBag)
	}
	
	fileprivate func displayErrorAlert(message:String) {
		
		let localized = LocalizedStrings.PhoneVerification.self
		
		
		let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)

		let tryAgainAction = UIAlertAction(title: localized.tryAgain, style: .cancel)
		let requestTokenAction = UIAlertAction(title: localized.requestNewSMSCode, style: .default) { action in
			_ = self.navigationController?.popViewController(animated: true)
		}
		
		alert.addAction(tryAgainAction)
		alert.addAction(requestTokenAction)
		navigationController?.present(alert, animated: true, completion: nil)
	}
	
	fileprivate func didVerifyPhoneNumber(_ verified: Bool) {
		
		if verified {
			let nav = navigationController as! AirMapPhoneVerificationNavController
			nav.phoneVerificationDelegate?.phoneVerificationDidVerifyPhoneNumber(verifiedPhoneNumber: phoneNumber)
		} else {
			//TODO: Localize
			displayErrorAlert(message: LocalizedStrings.PhoneVerification.verificationFailed)
		}
	}
}
