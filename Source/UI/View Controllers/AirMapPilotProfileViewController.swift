//
//  AirMapPilotProfileViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/21/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa
import libPhoneNumber_iOS

class AirMapPilotProfileViewController: UITableViewController {
	
	var pilot: Variable<AirMapPilot?>!
	
	@IBOutlet weak var fullName: UILabel!
	@IBOutlet weak var firstName: UITextField!
	@IBOutlet weak var lastName: UITextField!
	@IBOutlet weak var email: UITextField!
	@IBOutlet weak var phoneNumber: UITextField!
	@IBOutlet var saveButton: UIButton!
	
	private let numberFormatter = NBAsYouTypeFormatter()
	private let activityIndicator = ActivityIndicator()
	private let disposeBag = DisposeBag()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupBindings()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		AirMap
			.rx_getAuthenticatedPilot()
			.asOptional()
			.bindTo(pilot)
			.addDisposableTo(disposeBag)
	}
	
	override func canBecomeFirstResponder() -> Bool {
		return true
	}
	
	override var inputAccessoryView: UIView? {
		return saveButton
	}
	
	private func setupBindings() {
		
		firstName.rx_text
			.asObservable()
			.skip(1)
			.subscribeNext { [weak self] text in self?.pilot.value?.firstName = text }
			.addDisposableTo(disposeBag)

		lastName.rx_text
			.asObservable()
			.skip(1)
			.subscribeNext { [weak self] text in self?.pilot.value?.lastName = text }
			.addDisposableTo(disposeBag)

		let pilotObsl = pilot.asObservable().unwrap()
		
		pilotObsl
			.map { $0.firstName }.unwrap()
			.bindTo(firstName.rx_text)
			.addDisposableTo(disposeBag)
		
		pilotObsl
			.map { $0.lastName }.unwrap()
			.bindTo(lastName.rx_text)
			.addDisposableTo(disposeBag)
		
		pilotObsl
			.map { $0.email }
			.bindTo(email.rx_text)
			.addDisposableTo(disposeBag)
		
		pilotObsl
			.map { $0.phone }
			.map(unowned(self, AirMapPilotProfileViewController.formatPhoneNumber))
			.bindTo(phoneNumber.rx_text)
			.addDisposableTo(disposeBag)
		
		pilotObsl
			.map { [$0.firstName, $0.lastName].flatMap { $0 } }
			.map(fullName)
			.bindTo(fullName.rx_text)
			.addDisposableTo(disposeBag)

		[firstName.rx_text, lastName.rx_text]
			.combineLatest(fullName)
			.bindTo(fullName.rx_text)
			.addDisposableTo(disposeBag)
		
		activityIndicator.asObservable()
			.throttle(0.25, scheduler: MainScheduler.instance)
			.distinctUntilChanged()
			.bindTo(rx_loading)
			.addDisposableTo(disposeBag)
	}
	
	@IBAction func savePilot() {

		pilot
			.asObservable()
			.unwrap()
			.flatMap { [unowned self] pilot in
				AirMap.rx_updatePilot(pilot).trackActivity(self.activityIndicator)
			}
			.subscribe()
			.addDisposableTo(disposeBag)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "modalUpdatePhoneNumber" {
			let nav = segue.destinationViewController as! AirMapPhoneVerificationNavController
			nav.phoneVerificationDelegate = self
			let phoneVC = nav.viewControllers.first as! AirMapPhoneVerificationViewController
			phoneVC.pilot = pilot.value
		}
	}
	
	func fullName(names: [String]) -> String {
		return names.filter { !$0.isEmpty }.joinWithSeparator(" ")
	}
	
	func formatPhoneNumber(phone: String?) -> String {
		return numberFormatter.inputString(phone) ?? ""
	}
	
	@IBAction func unwindToPilotProfile(segue: UIStoryboardSegue) { /* Interface Builder hook; keep */ }

}

extension AirMapPilotProfileViewController: AirMapPhoneVerificationDelegate {
	
	func phoneVerificationDidVerifyPhoneNumber() {
		dismissViewControllerAnimated(true, completion: nil)
	}
}

