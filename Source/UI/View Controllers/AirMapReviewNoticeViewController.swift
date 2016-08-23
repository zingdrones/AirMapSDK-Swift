//
//  AirMapReviewNoticeViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/25/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources
import libPhoneNumber_iOS

class AirMapReviewNoticeViewController: UIViewController {
	
	var status: AirMapStatus!
	
	@IBOutlet var tableView: UITableView!
	
	private typealias RowData = (advisory: AirMapStatusAdvisory, notice: AirMapStatusRequirementNotice)
	
	private let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<Bool,RowData>>()
	private let disposeBag = DisposeBag()
	
	private lazy var advisoryNotices: [RowData] = {
		return self.status?.advisories
			.sort { $0.0.name < $0.1.name }
			.map { ($0, $0.requirements?.notice) }
			.filter { $0.1 != nil }
			.map { ($0.0, $0.1!) } ?? []
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.estimatedRowHeight = 44
		tableView.rowHeight = UITableViewAutomaticDimension
		
		dataSource.configureCell = { [weak self] dataSource, tableView, indexPath, rowData in
			let cell: UITableViewCell
			if rowData.notice.digital {
				cell = tableView.dequeueReusableCellWithIdentifier("digitalCell")!
			} else {
				cell = tableView.dequeueReusableCellWithIdentifier("noDigitalCell")!
			}
			cell.textLabel?.text = rowData.advisory.name
			cell.detailTextLabel?.text = self?.phoneStringFromE164(rowData.notice.phoneNumber ?? "")
			return cell
		}
		
		dataSource.titleForHeaderInSection = { sections, index -> String? in
			let digitalNotice = sections.sectionModels[index].model.boolValue
			return digitalNotice ? "Digital Notice" : "The following authorities in this area do not accept digital notice"
		}
		
		let digitalNotices = advisoryNotices.filter { $0.notice.digital == true }
		let regularNotices = advisoryNotices.filter { $0.notice.digital == false && $0.notice.phoneNumber != nil }
		
		let digitalSection = SectionModel(model: true, items: digitalNotices)
		let regularSection = SectionModel(model: false, items: regularNotices)
		
		let sections = [digitalSection, regularSection].filter { $0.items.count > 0 }
		
		Observable
			.just(sections)
			.bindTo(tableView.rx_itemsWithDataSource(dataSource))
			.addDisposableTo(disposeBag)
	}
	
	func phoneStringFromE164(number: String) -> String? {		
		do {
			let util = AirMapFlightNoticeCell.phoneUtil
			let phoneNumberObject = try util.parse(number, defaultRegion: nil)
			return try util.format(phoneNumberObject, numberFormat: NBEPhoneNumberFormat.NATIONAL)
		} catch {
			return number
		}
	}

}
