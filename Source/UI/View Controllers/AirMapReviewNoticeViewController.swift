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
            
            if digitalNotices.count == 0 && regularNotices.count == 0 {
				return NSLocalizedString("REVIEW_FLIGHT_PLAN_NOTICE_TAB_SECTION_HEADER_NO_NOTICES", bundle: AirMapBundle.core, value: "There are no notices for this flight.", comment: "Displayed in the flight plan review notices tab when there are no notices to display")
            }
            
			let digitalNotice = sections.sectionModels[index].model
			let acceptsDigitalNotice = NSLocalizedString("REVIEW_FLIGHT_NOTICE_TAB_ACCEPTS_NOTICE", bundle: AirMapBundle.core, value: "Accepts Digital Notice", comment: "Displayed for authorities that are setup to receive digital notice")
			let doesNotacceptsDigitalNotice = NSLocalizedString("REVIEW_FLIGHT_NOTICE_TAB_DOES_NOT_ACCEPT_NOTICE", bundle: AirMapBundle.core, value: "The following authorities in this area do not accept digital notice", comment: "Displayed for authorities that are NOT setup to receive digital notice")
			
			return digitalNotice ? acceptsDigitalNotice : doesNotacceptsDigitalNotice
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
