//
//  AirMapPhoneCountryViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/8/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

protocol AirMapPhoneCountrySelectorDelegate: class {
	func phoneCountrySelectorDidSelect(country name: String, country code: String)
	func phoneCountrySelectorDidCancel()
}

class AirMapPhoneCountryViewController: UITableViewController, AnalyticsTrackable {
	
	var screenName = "Phone Country Selector"
	weak var selectionDelegate: AirMapPhoneCountrySelectorDelegate?
	
	let locale = Locale.current
	var selectedCountryIdentifier: String!
	
	fileprivate var selectedCountryName: String! {
		return locale.localizedString(forRegionCode: selectedCountryIdentifier)
	}
	
	fileprivate typealias RowData = (code: String, name: String)
	fileprivate let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String,RowData>>()
	fileprivate let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupTable()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		trackView()
	}
	
	func setupTable() {
		
		tableView.dataSource = nil
		tableView.delegate = nil
		tableView.rx.setDelegate(self)

		let currentCountry: RowData = (code: selectedCountryIdentifier, name: selectedCountryName)
		
		let otherCountries: [RowData] = Locale.isoRegionCodes
			.map { ($0, self.locale.localizedString(forRegionCode: $0) ?? $0) }
			.sorted { $0.name < $1.name }
		
		let localized = LocalizedStrings.PhoneCountry.self

		let sections = [
			SectionModel(model: localized.selectedCountry, items: [currentCountry]),
			SectionModel(model: localized.otherCountry, items: otherCountries)
		]
		
		Observable.just(sections)
			.bindTo(tableView.rx.items(dataSource: dataSource))
			.disposed(by: disposeBag)
		
		dataSource.configureCell = { datasource, tableView, indexPath, row in
			let cell = tableView.dequeueReusableCell(withIdentifier: "phoneCountryCell")!
			cell.textLabel?.text = row.name
			return cell
		}
		
		tableView.rx.itemSelected.asObservable()
			.map(tableView.rx.model)
			.subscribe(onNext: { [weak self] (row: RowData) in
				self?.trackEvent(.tap, label: "Country Row")
				self?.selectionDelegate?.phoneCountrySelectorDidSelect(country: row.name, country: row.code)
			})
			.disposed(by: disposeBag)
	}
	
	// MARK: - UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		
		if indexPath.section == 0 {
			cell.accessoryType = .checkmark
		} else {
			cell.accessoryType = .none
		}
	}
	
}
