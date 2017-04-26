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

class AirMapAvailablePermitViewController: UITableViewController, AnalyticsTrackable {
	
	var screenName = "Permit Details"
	
	enum Mode {
		case select
		case review
	}
	
	@IBOutlet weak var nextButton: UIButton!
	@IBOutlet weak var doneButton: UIButton!
	
	var permit: Variable<AirMapAvailablePermit>!
    var pilotPermit =  Variable(nil as AirMapPilotPermit?)
	var organization: AirMapOrganization!
	var mode = Mode.select
	
	var customProperties: [AirMapPilotPermitCustomProperty] {
		return textFields.value.map { $0.property }
	}
	
	fileprivate typealias PropertyTextField = (property: AirMapPilotPermitCustomProperty, textField: UITextField)
	fileprivate let textFields = Variable([PropertyTextField]())
	
	fileprivate typealias SectionData = String
	fileprivate typealias RowData = (title: String?, subtitle: String?, customProperty: AirMapPilotPermitCustomProperty?, cellIdentifier: String)
	fileprivate let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<SectionData,RowData>>()
	
	fileprivate let disposeBag = DisposeBag()
	
	fileprivate let customFieldCell = "customFieldCell"
	fileprivate let permitDetailsCell = "permitDetailCell"
	fileprivate let permitDescriptionCell = "permitDescriptionCell"
	
	fileprivate func fetchPermitData() {
		
		AirMap.rx.getAvailablePermit(permit.value.id)
			.unwrap()
			.bind(to: permit)
			.disposed(by: disposeBag)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.title = permit.value.name
		
		setupBindings()
		setupTable()
		fetchPermitData()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		trackView()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "unwindFromNewPermitSelection" {
			trackEvent(.tap, label: "Select Permit")
		}
	}
	
	override var canBecomeFirstResponder : Bool {
		return mode == .select
	}
	
	override var inputAccessoryView: UIView? {
		return nextButton
	}
	
	@IBAction func endEditing() {
		view.endEditing(true)
	}
	
	fileprivate func setupBindings() {
		
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
            .bind(to: textFields)
            .disposed(by: disposeBag)
        
       
        pilotPermit
            .asObservable()
            .subscribeOn(MainScheduler.instance)
            .unwrap()
            .map { permit in
                permit.customProperties.map {[unowned self] property in
                    let textField = UITextField()
                    textField.placeholder = property.label
                    
                    if self.mode == .review {
                        textField.text = property.value
                        textField.isEnabled = false
                    }
                    
                    return (property, textField)
                }
            }
            .bind(to: textFields)
            .disposed(by: disposeBag)
		
		Observable
			.combineLatest(permit.asObservable(), textFields.asObservable()) { ($0, $1) }
			.subscribeOn(MainScheduler.instance)
			.map { [unowned self] (permit, propertTextFields) in
				self.sectionModels(permit, textFields: propertTextFields)
			}
			.bind(to: tableView.rx.items(dataSource: dataSource))
			.disposed(by: disposeBag)
	}
	
	fileprivate func sectionModels(_ permit: AirMapAvailablePermit, textFields: [PropertyTextField]) -> [SectionModel<SectionData,RowData>] {
		
		let localized = LocalizedStrings.AvailablePermit.self
		
		var sections = [SectionModel<String,RowData>]()
		
		let permitDescription: RowData = (title: permit.info, subtitle: nil, customProperty: nil,  cellIdentifier: permitDescriptionCell)
		
		let descriptionSection = SectionModel(model: localized.sectionHeaderDescription, items: [permitDescription])
		sections.append(descriptionSection)
		
		let validity: RowData = (
			title: localized.rowTitleValidity,
			subtitle: permit.validityString(),
			customProperty: nil,
			cellIdentifier: permitDetailsCell)
		
		let singleUse: RowData = (
			title: localized.rowTitleSingleUse,
			subtitle: permit.singleUse ? localized.rowValueSingleUseValueTrue : localized.rowValueSingleUseValueFalse,
			customProperty: nil,
			cellIdentifier: permitDetailsCell)
		
		let items = [validity, singleUse].filter {$0.subtitle != nil}
		
		let detailsSection = SectionModel(model: localized.rowTitleDetails, items: items)
		sections.append(detailsSection)
		
		let customPropertyData = textFields.map { data in
			(title: data.property.label, subtitle: nil, customProperty: data.property, cellIdentifier: customFieldCell) as RowData
		}
		
		if customPropertyData.count > 0 {
			let customPropertiesSection = SectionModel(model: localized.sectionHeaderCustomProperties, items: customPropertyData)
			sections.append(customPropertiesSection)
		}
	
		return sections
	}
	
	fileprivate func textFieldsAreValid() -> Bool {
		
		return textFields.value
            .filter { $0.property.required == true }
            .map { !($0.textField.text?.isEmpty ?? false) }
			.reduce(true) { current, next in
				current && next
		}
	}
	
	fileprivate func setupTable() {
		
		dataSource.configureCell = { [unowned self] dataSource, tableView, indexPath, rowData in
			if let property = rowData.customProperty {
				let cell = tableView.dequeueReusableCell(withIdentifier: rowData.cellIdentifier) as! AirMapPermitCustomPropertyCell
				
				let tf = self.textFields.value.map({$1})[indexPath.row]
				
				tf.autocorrectionType = .no
				tf.text = property.value
				
				if self.mode == .review {
					tf.isEnabled = false
					tf.placeholder = nil
                    tf.text = property.value
				} else {
					tf.isEnabled = true
                    tf.placeholder = property.required ? "* \(property.label)" : property.label
				}
	
				if property.label.lowercased().range(of: "email") != nil {
					tf.keyboardType = .emailAddress
					tf.autocapitalizationType = .none
				} else {
					tf.keyboardType = .default
					tf.autocapitalizationType = .words
				}
				
				tf.inputAccessoryView = self.doneButton
				tf.frame = cell.textField.frame
				
				tf.rx.text
					.do( onNext: { property.value = $0 ?? "" } )
					.mapToVoid()
					.map(unowned(self, AirMapAvailablePermitViewController.textFieldsAreValid))
					.bind(to: self.nextButton.rx.isEnabled)
					.disposed(by: self.disposeBag)
				
				cell.addSubview(tf)
				cell.textField.isHidden = true

				return cell
			} else {
				let cell = tableView.dequeueReusableCell(withIdentifier: rowData.cellIdentifier)!
				cell.textLabel?.text = rowData.title
				cell.detailTextLabel?.text = rowData.subtitle
				return cell
			}
		}
		
		dataSource.titleForHeaderInSection = { dataSource, index in
			dataSource.sectionModels[index].identity
		}
		
		tableView.estimatedRowHeight = 50
	}
	
}
