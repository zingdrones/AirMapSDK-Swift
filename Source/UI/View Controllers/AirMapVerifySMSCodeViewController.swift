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
	
	fileprivate let disposeBag = DisposeBag()
	fileprivate let activityIndicator = ActivityIndicator()
	
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
			.map { $0?.characters.count == Config.AirMapApi.smsCodeLength }
			.bindTo(submitButton.rx.isEnabled)
			.addDisposableTo(disposeBag)
		
		activityIndicator.asObservable()
			.throttle(0.25, scheduler: MainScheduler.instance)
			.distinctUntilChanged()
			.bindTo(rx_loading)
			.addDisposableTo(disposeBag)
	}
	
	@IBAction func submitSMSCode() {
		
		trackEvent(.tap, label: "Submit Button")
		
		smsCode.resignFirstResponder()
		
		AirMap.rx.verifySMS(smsTextField.text!)
			.trackActivity(activityIndicator)
			.map { $0.verified }
			.subscribe(
				onNext: (unowned(self, AirMapVerifySMSCodeViewController.didVerifyPhoneNumber)),
				onError: { [unowned self] error in
					self.trackEvent(.save, label: "Error", value: NSNumber(value: (error as NSError).code))
				},
				onCompleted: { [unowned self] _ in
					self.trackEvent(.save, label: "Success")
				}
			)
			.addDisposableTo(disposeBag)
	}
	
	fileprivate func didVerifyPhoneNumber(_ verified: Bool) {
		
		if verified {
			let nav = navigationController as! AirMapPhoneVerificationNavController
			nav.phoneVerificationDelegate?.phoneVerificationDidVerifyPhoneNumber()
		} else {
			//TODO: Handle error
			navigationController?.popViewController(animated: true)
		}
	}
	
}
