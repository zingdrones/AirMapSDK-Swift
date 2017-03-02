//
//  AirMapCreateAircraftViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/27/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class AirMapCreateAircraftViewController: UITableViewController, AnalyticsTrackable {
	
	var screenName: String {
		switch mode {
		case .create:
			return "Create Aircraft"
		case .update:
			return "Update Aircraft"
		}
	}
	
	@IBOutlet var nextButton: UIButton!
	@IBOutlet weak var nickName: UITextField!
	@IBOutlet weak var makeAndModel: UILabel!
	@IBOutlet weak var makeAndModelCell: UITableViewCell!
	
	enum EditMode {
		case create
		case update
	}
	
	var aircraft = AirMapAircraft()

	fileprivate var mode: EditMode {
		return aircraft.aircraftId == nil ? .create : .update
	}
	
	fileprivate let activityIndicator = ActivityIndicator()
	fileprivate var model = Variable(nil as AirMapAircraftModel?)
	fileprivate let disposeBag = DisposeBag()
	
	override var navigationController: AirMapAircraftNavController? {
		return super.navigationController as? AirMapAircraftNavController
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		switch mode {
		case .create:
			navigationItem.title = LocalizedString.Aircraft.titleCreate
			
		case .update:
			navigationItem.title = LocalizedString.Aircraft.titleUpdate

			tableView.allowsSelection = false
			nickName.text = aircraft.nickname
			model.value = aircraft.model
			makeAndModelCell.accessoryType = .none
			makeAndModelCell.textLabel?.alpha = 0.5
		}
		setupBindings()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		trackView()
		
		if (nickName.text ?? "").isEmpty || mode == .update {
			nickName.becomeFirstResponder()
		} else {
			self.becomeFirstResponder()
		}
	}
	
	override var canBecomeFirstResponder : Bool {
		return true
	}
	
	override var inputAccessoryView: UIView? {
		return nextButton
	}
	
	fileprivate func setupBindings() {

		nickName.rx.text.asObservable()
			.subscribe( onNext: { [weak self] name in
				self?.aircraft.nickname = name
			})
			.disposed(by: disposeBag)
		
		model.asObservable()
			.unwrap()
			.do( onNext: { [unowned self] model in
				self.aircraft.model = model
			})
			.map { [$0.manufacturer.name, $0.name].flatMap { $0 }.joined(separator: " ") }
			.bindTo(makeAndModel.rx.text)
			.disposed(by: disposeBag)
		
		Observable
			.combineLatest(model.asObservable(), nickName.rx.text) { (model: $0.0, nickName: $0.1) }
			.map { $0.model != nil && !($0.nickName ?? "").isEmpty }
			.bindTo(nextButton.rx.isEnabled)
			.disposed(by: disposeBag)
		
		activityIndicator.asObservable()
			.throttle(0.25, scheduler: MainScheduler.instance)
			.distinctUntilChanged()
			.bindTo(rx_loading)
			.disposed(by: disposeBag)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "modalModel" {
			trackEvent(.tap, label: "Make & Model")
			let nav = segue.destination as! AirMapAircraftModelNavController
			nav.aircraftModelSelectionDelegate = self
		}
	}
	
	@IBAction func unwindToCreateAircraft(_ segue: UIStoryboardSegue) { /* Interface Builder hook; keep */ }
	
	@IBAction func save() {
		
		trackEvent(.tap, label: "Save Button")

		let action: Observable<AirMapAircraft>
		switch mode {
		case .create:
			action = AirMap.rx.createAircraft(aircraft).trackActivity(activityIndicator)
		case .update:
			action = AirMap.rx.updateAircraft(aircraft).trackActivity(activityIndicator)
		}

		action
			.subscribe(onCompleted: { [weak self] _ in
				self?.navigationController?.aircraftDelegate?
					.aircraftNavController(self!.navigationController!, didCreateOrModify: self!.aircraft)
			})
			.disposed(by: disposeBag)
	}

}

extension AirMapCreateAircraftViewController: AirMapAircraftModelSelectionDelegate {
	
	func didSelectAircraftModel(_ model: AirMapAircraftModel?) {
		self.model.value = model
		dismiss(animated: true, completion: nil)
	}

}
