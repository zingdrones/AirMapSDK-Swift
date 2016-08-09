//
//  AirMapPilotProfileViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/21/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class AirMapPilotProfileViewController: UITableViewController {
	
	var pilot: Variable<AirMapPilot?>!
	
	@IBOutlet weak var fullName: UILabel!
	@IBOutlet weak var firstName: UITextField!
	@IBOutlet weak var lastName: UITextField!
	@IBOutlet weak var email: UITextField!
	@IBOutlet weak var phoneNumber: UITextField!
	@IBOutlet var saveButton: UIButton!
	
	private let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupBindings()
		
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
			.unwrap()
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
	}
	
	@IBAction func savePilot() {

		pilot
			.asObservable()
			.unwrap()
			.flatMap(AirMap.rx_updatePilot)
			.subscribe()
			.addDisposableTo(disposeBag)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "modalUpdatePhoneNumber" {
			let nav = segue.destinationViewController as! UINavigationController
			let phoneVC = nav.viewControllers.first as! AirMapPhoneVerificationViewController
			phoneVC.pilot = pilot.value
		}
	}
	
	func fullName(names: [String]) -> String {
		return names.filter { !$0.isEmpty }.joinWithSeparator(" ")
	}
	
	@IBAction func unwindToPilotProfile(segue: UIStoryboardSegue) { /* Interface Builder hook; keep */ }

}

