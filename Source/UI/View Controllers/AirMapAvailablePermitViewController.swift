//
//  AirMapAvailablePermitViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/21/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

class AirMapAvailablePermitViewController: UITableViewController {
	
	enum Mode {
		case Select
		case Review
	}
	
	@IBOutlet weak var nextButton: UIButton!
	@IBOutlet weak var doneButton: UIButton!
	
	var permit: Variable<AirMapAvailablePermit>!
	var organization: AirMapOrganization!
	var mode = Mode.Select
	
	var customProperties: [AirMapPilotPermitCustomProperty] {
		return textFields.value.map { $0.property }
	}
	
	private typealias PropertyTextField = (property: AirMapPilotPermitCustomProperty, textField: UITextField)
	private let textFields = Variable([PropertyTextField]())
	
	private typealias SectionData = String
	private typealias RowData = (title: String?, subtitle: String?, customProperty: AirMapPilotPermitCustomProperty?, cellIdentifier: String)
	private let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<SectionData,RowData>>()
	
	private let disposeBag = DisposeBag()
	
	private let customFieldCell = "customFieldCell"
	private let permitDetailsCell = "permitDetailCell"
	private let permitDescriptionCell = "permitDescriptionCell"
	
	private func fetchPermitData() {
		
		AirMap.rx_getAvailablePermit(permit.value.id)
			.unwrap()
			.bindTo(permit)
			.addDisposableTo(disposeBag)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.title = permit.value.name
		
		setupBindings()
		setupTable()
		fetchPermitData()
	}
	
	override func canBecomeFirstResponder() -> Bool {
		return mode == .Select
	}
	
	override var inputAccessoryView: UIView? {
		return nextButton
	}
	
	@IBAction func endEditing() {
		view.endEditing(true)
	}
	
	private func setupBindings() {
		
		tableView.dataSource = nil
		
		permit
			.asObservable()
			.subscribeOn(MainScheduler.instance)
			.map { permit in
				permit.customProperties.map { property in
					let textField = UITextField()
					textField.placeholder = property.label
					return (property, textField)
				}
		}
		.bindTo(textFields)
		.addDisposableTo(disposeBag)
		
		Observable
			.combineLatest(permit.asObservable(), textFields.asObservable()) { ($0, $1) }
			.subscribeOn(MainScheduler.instance)
			.map { [unowned self] (permit, propertTextFields) in
				self.sectionModels(permit, textFields: propertTextFields)
			}
			.bindTo(tableView.rx_itemsWithDataSource(dataSource))
			.addDisposableTo(disposeBag)
	}
	
	private func sectionModels(permit: AirMapAvailablePermit, textFields: [PropertyTextField]) -> [SectionModel<SectionData,RowData>] {
		
		var sections = [SectionModel<String,RowData>]()
		
		let permitDescription: RowData = (title: permit.info, subtitle: nil, customProperty: nil,  cellIdentifier: permitDescriptionCell)
		
		let descriptionSection = SectionModel(model: "Description", items: [permitDescription])
		sections.append(descriptionSection)
		
		let validity: RowData = (
			title: "Valid for",
			subtitle: permit.validityString(),
			customProperty: nil,
			cellIdentifier: permitDetailsCell)
		
		let singleUse: RowData = (
			title: "Single Use",
			subtitle: permit.singleUse ? "Yes":"No",
			customProperty: nil,
			cellIdentifier: permitDetailsCell)
		
//		let price: RowData = (
//			title: "Price",
//			subtitle: "Free",
//			customProperty: nil,
//			cellIdentifier: permitDetailsCell)
		
		let items = [validity, singleUse].filter {$0.subtitle != nil}
		let detailsSection = SectionModel(model: "Details", items: items)
		sections.append(detailsSection)
		
		let customPropertyData = textFields.map { data in
			(title: data.property.label, subtitle: nil, customProperty: data.property, cellIdentifier: customFieldCell) as RowData
		}
		
		if customPropertyData.count > 0 {
			let customPropertiesSection = SectionModel(model: "Form Fields (* Required)", items: customPropertyData)
			sections.append(customPropertiesSection)
		}
	
		return sections
	}
	
	private func textFieldsAreValid() -> Bool {
		
		return textFields.value
            .filter { $0.property.required == true }
            .map { !($0.textField.text?.isEmpty ?? false) }
			.reduce(true) { current, next in
				current && next
		}
	}
	
	private func setupTable() {
		
		dataSource.configureCell = { [unowned self] dataSource, tableView, indexPath, rowData in
			if let property = rowData.customProperty {
				let cell = tableView.dequeueReusableCellWithIdentifier(rowData.cellIdentifier) as! AirMapPermitCustomPropertyCell
				
				// TODO: Clean this up ^AM
	
				let tf = self.textFields.value.map({$1})[indexPath.row]
				
				tf.autocorrectionType = .No
				tf.text = property.value
				
				if self.mode == .Review {
					tf.enabled = false
					tf.placeholder = nil
                    tf.text = property.value
				} else {
					tf.enabled = true
                    tf.placeholder = property.required ? "* \(property.label)" : property.label
				}
	
				if property.label.lowercaseString.rangeOfString("email") != nil {
					tf.keyboardType = .EmailAddress
					tf.autocapitalizationType = .None
				} else {
					tf.keyboardType = .Default
					tf.autocapitalizationType = .Words
				}
				
				tf.inputAccessoryView = self.doneButton
				tf.frame = cell.textField.frame
				
				tf.rx_text.asObservable()
					.doOnNext { property.value = $0 }
					.mapToVoid()
					.map(unowned(self, AirMapAvailablePermitViewController.textFieldsAreValid))
					.bindTo(self.nextButton.rx_enabled)
					.addDisposableTo(self.disposeBag)
				
				cell.addSubview(tf)
				cell.textField.hidden = true

				return cell
			} else {
				let cell = tableView.dequeueReusableCellWithIdentifier(rowData.cellIdentifier)!
				cell.textLabel?.text = rowData.title
				cell.detailTextLabel?.text = rowData.subtitle
				return cell
			}
		}
		
		dataSource.titleForHeaderInSection = { [weak self] indexPath in
			self?.dataSource.sectionAtIndex(indexPath.section).identity
		}
		
		tableView.estimatedRowHeight = 50
	}
	
}
