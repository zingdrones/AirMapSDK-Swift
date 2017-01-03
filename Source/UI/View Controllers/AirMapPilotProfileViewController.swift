//
//  AirMapPilotProfileViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/21/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources
import libPhoneNumber_iOS

public class AirMapPilotProfileField {
	
	public enum FieldType {
		case Text
		case Email
		case PhoneNumber
		
		var type: String {
			switch self {
			case .Text: return "text"
			case .Email: return "email"
			case .PhoneNumber: return "phone"
			}
		}
	}
	
	let label: String
	let key: String
	
	internal let rx_value = PublishSubject<String?>()
	
	public var type: FieldType = .Text
	
	public init(label: String, key: String, type: FieldType = .Text) {
		self.label = label
		self.type = type
		self.key = key
	}
}

class AirMapFormTextField: UITableViewCell {
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var label: UILabel!
}

class AirMapPilotProfileViewController: UITableViewController, AnalyticsTrackable {
	
	var screenName = "Pilot Profile"
	
	var customFields = [AirMapPilotProfileField]()

	var pilot: Variable<AirMapPilot?>!
	
	@IBOutlet weak var fullName: UILabel!
	@IBOutlet weak var statisticsLabel: UILabel!
	@IBOutlet var saveButton: UIButton!
	
	private typealias Model = SectionModel<String,AirMapPilotProfileField>
	private let dataSource = RxTableViewSectionedReloadDataSource<Model>()
	private let activityIndicator = ActivityIndicator()
	private let disposeBag = DisposeBag()
	
	enum Section: Int {
		case PilotInfo
		case CustomInfo
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.dataSource = nil
		tableView.delegate = nil
		
		let faaReg = AirMapPilotProfileField(label: "FAA Registration Number", key: "faa_registration_number")
		customFields.append(faaReg)

		setupBindings()
		setupTableView()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		guard pilot.value == nil else { return }
		
		AirMap.rx_getAuthenticatedPilot().asOptional()
			.trackActivity(activityIndicator)
			.bindTo(pilot)
			.addDisposableTo(disposeBag)
		
		trackView()
	}
	
	override func canBecomeFirstResponder() -> Bool {
		return true
	}
	
	override var inputAccessoryView: UIView? {
		return saveButton
	}
	
	private func sectionModel(pilot: AirMapPilot) -> [Model] {
		
		let firstNameField = AirMapPilotProfileField(label: "First Name", key: "firstName")
		let lastNameField  = AirMapPilotProfileField(label: "Last Name", key: "lastName")
		let usernameField  = AirMapPilotProfileField(label: "Username", key: "username")
		let emailField     = AirMapPilotProfileField(label: "Email", key: "email", type: .Email)
		let phoneField     = AirMapPilotProfileField(label: "Phone Number", key: "phone", type: .PhoneNumber)
		
		let pilotFields = [firstNameField, lastNameField, usernameField, emailField, phoneField]
		
		pilotFields.forEach { field in
			
			field.rx_value.skip(1).asDriver(onErrorJustReturn: nil)
				.driveNext { pilot.setValue($0, forKey: field.key) }
				.addDisposableTo(disposeBag)
		}
		
		customFields.forEach { customField in

			customField.rx_value.skip(1).asDriver(onErrorJustReturn: nil)
				.driveNext { text in pilot.setAppMetadata(text, forKey: customField.key) }
				.addDisposableTo(disposeBag)
		}
		
		[firstNameField.rx_value.asDriver(onErrorJustReturn: nil), lastNameField.rx_value.asDriver(onErrorJustReturn: nil)]
			.combineLatest(fullNameString)
			.drive(fullName.rx_text)
			.addDisposableTo(disposeBag)
		
		return [
			Model(model: "Personal Info", items: pilotFields),
			Model(model: "Additional Info", items: customFields)
		]
	}
	
	private func setupTableView() {
		
		tableView.estimatedRowHeight = 50
		tableView.rowHeight = UITableViewAutomaticDimension

		dataSource.configureCell = { [unowned self] dataSource, tableView, indexPath, field in
			let cell: AirMapFormTextField
			
			let cellIdentifier: String
			switch field.type  {
			case .Text:
				cellIdentifier = "TextCell"
			case .Email:
				cellIdentifier = "EmailCell"
			case .PhoneNumber:
				cellIdentifier = "PhoneCell"
			}
			
			cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! AirMapFormTextField
			cell.label.text = field.label

			let pilot = self.pilot.value
			
			switch Section(rawValue: indexPath.section)! {
			case .PilotInfo:
				if let value = pilot?.valueForKey(field.key) as? String {
					cell.textField.rx_text.onNext(value)
				}
			case .CustomInfo:
				if let value = pilot?.appMetadata()[field.key] as? String {
					cell.textField.rx_text.onNext(value)
				}
			}

			cell.textField.rx_text.asOptional()
				.bindTo(field.rx_value)
				.addDisposableTo(self.disposeBag)
			
			return cell
		}
		
		dataSource.titleForHeaderInSection = { datasource, section in
			datasource.sectionAtIndex(section).model
		}
	}
	
	private func setupBindings() {
		
		pilot.asObservable()
			.unwrap()
			.map(sectionModel)
			.observeOn(MainScheduler.instance)
			.bindTo(tableView.rx_itemsWithDataSource(dataSource))
			.addDisposableTo(disposeBag)
		
		pilot.asObservable()
			.unwrap()
			.observeOn(MainScheduler.instance)
			.subscribeNext(unowned(self, AirMapPilotProfileViewController.configureStats))
			.addDisposableTo(disposeBag)
		
		activityIndicator.asObservable()
			.throttle(0.25, scheduler: MainScheduler.instance)
			.distinctUntilChanged()
			.bindTo(rx_loading)
			.addDisposableTo(disposeBag)
	}
	
	@IBAction func savePilot() {
		
		trackEvent(.tap, label: "Save")

		guard let pilot = pilot.value else { return }

		AirMap.rx_updatePilot(pilot)
			.trackActivity(activityIndicator)
			.doOnError { error in
				self.trackEvent(.save, label: "Error", value: (error as NSError).code)
			}
			.doOnCompleted { [unowned self] in
				self.view.endEditing(true)
				self.dismissViewControllerAnimated(true, completion: nil)
				self.trackEvent(.save, label: "Success")
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
	
	private func fullNameString(names: [String?]) -> String {
		return names.flatMap { $0 }.joinWithSeparator(" ").uppercaseString
	}
	
	private func configureStats(pilot: AirMapPilot) {
		statisticsLabel.text = "\(pilot.statistics.totalAircraft) Aircraft, \(pilot.statistics.totalFlights) Flights"
	}
	
	@IBAction func unwindToPilotProfile(segue: UIStoryboardSegue) { /* Interface Builder hook; keep */ }

}

extension AirMapPilotProfileViewController: AirMapPhoneVerificationDelegate {
	
	func phoneVerificationDidVerifyPhoneNumber() {
		dismissViewControllerAnimated(true, completion: nil)
	}
}
