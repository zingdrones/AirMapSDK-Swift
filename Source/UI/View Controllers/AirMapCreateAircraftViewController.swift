//
//  AirMapCreateAircraftViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/27/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class AirMapCreateAircraftViewController: UITableViewController {
	
	var aircraft: AirMapAircraft!
	
	@IBOutlet var nextButton: UIButton!
	@IBOutlet weak var nickName: UITextField!
	@IBOutlet weak var makeAndModel: UILabel!
	@IBOutlet weak var makeAndModelCell: UITableViewCell!
	
	fileprivate enum UseCase {
		case create
		case update
	}
	
	fileprivate var mode: UseCase {
		return aircraft?.id == nil ? .create : .update
	}
	
	fileprivate var model = Variable(nil as AirMapAircraftModel?)
	
	private let activityIndicator = ActivityTracker()
	private let disposeBag = DisposeBag()
	
	override var navigationController: AirMapAircraftNavController? {
		return super.navigationController as? AirMapAircraftNavController
	}
	
	// MARK: - View Lifecycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		switch mode {
		case .create:
			navigationItem.title = LocalizedStrings.Aircraft.titleCreate
			
		case .update:
			navigationItem.title = LocalizedStrings.Aircraft.titleUpdate

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
		
		if ((nickName.text ?? "").isEmpty) || (mode == .update) {
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
	
	// MARK: - Setup
	
	fileprivate func setupBindings() {

		let nickNameObs = nickName.rx.text.asObservable()
		let modelObs = model.asObservable()
		
		Observable.combineLatest(nickNameObs, modelObs) { $0 }
			.subscribe(onNext: { [unowned self] nickname, model in
				
				switch self.mode {
				case .create:
					guard let nickname = nickname, let model = model else { return }
					self.aircraft = AirMapAircraft(model: model, nickname: nickname)
				case .update:
					guard let nickname = nickname else { return }
					self.aircraft.nickname = nickname
				}
			})
			.disposed(by: disposeBag)
		
		model.asObservable()
			.unwrap()
			.map { [$0.manufacturer.name, $0.name].flatMap { $0 }.joined(separator: " ") }
			.bind(to: makeAndModel.rx.text)
			.disposed(by: disposeBag)
		
		Observable
			.combineLatest(modelObs, nickNameObs) { (model: $0.0, nickName: $0.1) }
			.map { $0.model != nil && !($0.nickName ?? "").isEmpty }
			.bind(to: nextButton.rx.isEnabled)
			.disposed(by: disposeBag)
		
		activityIndicator.asObservable()
			.throttle(0.25, scheduler: MainScheduler.instance)
			.distinctUntilChanged()
			.bind(to: rx_loading)
			.disposed(by: disposeBag)
	}
	
	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "modalModel" {
			trackEvent(.tap, label: "Make & Model")
			let nav = segue.destination as! AirMapAircraftModelNavController
			nav.aircraftModelSelectionDelegate = self
		}
	}
	
	@IBAction func unwindToCreateAircraft(_ segue: UIStoryboardSegue) { /* Interface Builder hook; keep */ }
	
	// MARK: - Actions
	
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
			.do(onCompleted: { [weak self] _ in
				self?.resignFirstResponder()
				self?.navigationController?.aircraftDelegate?
					.aircraftNavController(self!.navigationController!, didCreateOrModify: self!.aircraft)
			})
			.subscribe()
			.disposed(by: disposeBag)
	}
}

extension AirMapCreateAircraftViewController: AirMapAircraftModelSelectionDelegate {
	
	func didSelectAircraftModel(_ model: AirMapAircraftModel?) {
		self.model.value = model
		dismiss(animated: true, completion: nil)
	}

}

extension AirMapCreateAircraftViewController: AnalyticsTrackable {
	
	var screenName: String {
		switch mode {
		case .create:
			return "Create Aircraft"
		case .update:
			return "Update Aircraft"
		}
	}
}
