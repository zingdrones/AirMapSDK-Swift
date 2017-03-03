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
	
	fileprivate typealias RowData = (advisory: AirMapStatusAdvisory, notice: AirMapStatusRequirementNotice)
	
	fileprivate let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<Bool,RowData>>()
	fileprivate let disposeBag = DisposeBag()
	
	fileprivate lazy var advisoryNotices: [RowData] = {
        
        let advisories:[AirMapStatusAdvisory] = self.status?.advisories
            .filterDuplicates { (left, right) in
                let notNil = left.organizationId != nil && right.organizationId != nil
                let notAirport = left.type != AirMapAirspaceType.airport && right.type != AirMapAirspaceType.airport
                return notNil && notAirport && left.organizationId == right.organizationId
            } ?? []
        
		return advisories
			.sorted { $0.0.name < $0.1.name }
			.map { ($0, $0.requirements?.notice) }
			.filter { $0.1 != nil }
			.map { ($0.0, $0.1!) } ?? []
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
        let digitalNotices:[RowData] = advisoryNotices.filter { $0.notice.digital == true }
        let regularNotices:[RowData] = advisoryNotices.filter { $0.notice.digital == false }
		
		tableView.estimatedRowHeight = 44
		tableView.rowHeight = UITableViewAutomaticDimension
		
		dataSource.configureCell = { dataSource, tableView, indexPath, rowData in
            let cellIdentifier = rowData.notice.digital ? "digitalCell" : "noDigitalCell"
		    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! AirMapFlightNoticeCell
            cell.advisory = rowData.advisory
            
			return cell
		}
		
		dataSource.titleForHeaderInSection = { sections, index -> String? in
			
			let localized = LocalizedStrings.ReviewFlightPlanNotices.self
			
            if digitalNotices.count == 0 && regularNotices.count == 0 {
				localized.headerNoNotices
            }
            
			let digitalNotice = sections.sectionModels[index].model
			
			return digitalNotice ? localized.acceptsDigitalNotice : localized.doesNotacceptsDigitalNotice
		}
        
		let digitalSection = SectionModel(model: true, items: digitalNotices)
		let regularSection = SectionModel(model: false, items: regularNotices)
        var sections = [digitalSection, regularSection].filter { $0.items.count > 0 }
		
        if digitalNotices.count == 0 && regularNotices.count == 0 {
            sections = [SectionModel(model: false, items: [])]
        }
        
		Observable
			.just(sections)
			.bindTo(tableView.rx.items(dataSource: dataSource))
			.disposed(by: disposeBag)
	}
	
	func phoneStringFromE164(_ number: String) -> String? {		
		do {
			let util = AirMapFlightNoticeCell.phoneUtil
			let phoneNumberObject = try util.parse(number, defaultRegion: nil)
			return try util.format(phoneNumberObject, numberFormat: NBEPhoneNumberFormat.NATIONAL)
		} catch {
			return number
		}
	}

}
