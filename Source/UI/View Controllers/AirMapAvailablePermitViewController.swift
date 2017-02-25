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
			.bindTo(permit)
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
            .bindTo(textFields)
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
            .bindTo(textFields)
            .disposed(by: disposeBag)
		
		Observable
			.combineLatest(permit.asObservable(), textFields.asObservable()) { ($0, $1) }
			.subscribeOn(MainScheduler.instance)
			.map { [unowned self] (permit, propertTextFields) in
				self.sectionModels(permit, textFields: propertTextFields)
			}
			.bindTo(tableView.rx.items(dataSource: dataSource))
			.disposed(by: disposeBag)
	}
	
	fileprivate func sectionModels(_ permit: AirMapAvailablePermit, textFields: [PropertyTextField]) -> [SectionModel<SectionData,RowData>] {
		
		var sections = [SectionModel<String,RowData>]()
		
		let permitDescription: RowData = (title: permit.info, subtitle: nil, customProperty: nil,  cellIdentifier: permitDescriptionCell)
		
		let descriptionSectionTitle = NSLocalizedString("PERMIT_DETAIL_SECTION_TITLE_DESCRIPTION", bundle: AirMapBundle.core, value: "Description", comment: "Title for the Description section of the permit detail view")
		let descriptionSection = SectionModel(model: descriptionSectionTitle, items: [permitDescription])
		sections.append(descriptionSection)
		
		let validityRowTitle = NSLocalizedString("PERMIT_DETAIL_ROW_TITLE_VALIDITY", bundle: AirMapBundle.core, value: "Valid for", comment: "Title for the row that shows the temporal validity or expiration of the permit")
		let validity: RowData = (
			title: validityRowTitle,
			subtitle: permit.validityString(),
			customProperty: nil,
			cellIdentifier: permitDetailsCell)
		
		let singleUseRowTitle = NSLocalizedString("PERMIT_DETAIL_ROW_TITLE_SINGLE_USE", bundle: AirMapBundle.core, value: "Single use", comment: "Title for the row that describes if the permit can be used more than once.")
		let singleUseTrueValue = NSLocalizedString("PERMIT_DETAIL_ROW_VALUE_SINGLE_USE_TRUE", bundle: AirMapBundle.core, value: "Yes", comment: "Value for when single use is true")
		let singleUseFalseValue = NSLocalizedString("PERMIT_DETAIL_ROW_VALUE_SINGLE_USE_FALSE", bundle: AirMapBundle.core, value: "No", comment: "Value for when single use is false")
		
		let singleUse: RowData = (
			title: singleUseRowTitle,
			subtitle: permit.singleUse ? singleUseTrueValue : singleUseFalseValue,
			customProperty: nil,
			cellIdentifier: permitDetailsCell)
		
		let items = [validity, singleUse].filter {$0.subtitle != nil}
		
		let detailsSectionTitle = NSLocalizedString("PERMIT_DETAIL_SECTION_TITLE_DETAILS", bundle: AirMapBundle.core, value: "Details", comment: "Title for the Details section of the permit detail view")

		let detailsSection = SectionModel(model: detailsSectionTitle, items: items)
		sections.append(detailsSection)
		
		let customPropertyData = textFields.map { data in
			(title: data.property.label, subtitle: nil, customProperty: data.property, cellIdentifier: customFieldCell) as RowData
		}
		
		if customPropertyData.count > 0 {
			let customPropertiesSectionTitle = NSLocalizedString("PERMIT_DETAIL_SECTION_TITLE_CUSTOM_PROPERTIES", bundle: AirMapBundle.core, value: "Form Fields (* Required)", comment: "Title for the Custom Properties section of the permit detail view. '*' denotes a required field")
			let customPropertiesSection = SectionModel(model: customPropertiesSectionTitle, items: customPropertyData)
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
					.bindTo(self.nextButton.rx.isEnabled)
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
		
		dataSource.titleForHeaderInSection = { [weak self] dataSource, index in
			dataSource.sectionModels[index].identity
		}
		
		tableView.estimatedRowHeight = 50
	}
	
}
