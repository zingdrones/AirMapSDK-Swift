//
//  AirMapFlightNoticeViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/21/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

class AirMapFlightNoticeViewController: UIViewController, AnalyticsTrackable {
	
	var screenName = "Create Flight - Flight Notices"
	
	@IBOutlet var submitNoticeHeader: UIView!
	@IBOutlet var noticeUnavailableHeader: UIView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var submitNoticeSwitch: UISwitch!
		
	override var navigationController: AirMapFlightPlanNavigationController? {
		return super.navigationController as? AirMapFlightPlanNavigationController
	}
	fileprivate typealias SectionData = (digital: Bool, headerView: UIView?)
	fileprivate typealias RowData = AirMapStatusAdvisory
	fileprivate typealias SectionDataModel = SectionModel<SectionData, RowData>

	fileprivate let dataSource = RxTableViewSectionedReloadDataSource<SectionDataModel>()
	fileprivate let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupBindings()
		tableView.estimatedRowHeight = 44
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		trackView()
	}
	
	fileprivate func setupBindings() {
		
        let advisories:[AirMapStatusAdvisory] = navigationController!.status.value!.advisories
            .filterDuplicates { (left, right) in
                let notNil = left.organizationId != nil && right.organizationId != nil
                let notAirport = left.type != AirMapAirspaceType.airport && right.type != AirMapAirspaceType.airport
                return notNil && notAirport && left.organizationId == right.organizationId
            }
		
        var sections = [SectionDataModel]()
		
        let digitalNotices: [AirMapStatusAdvisory] = advisories
            .filter { $0.requirements?.notice?.digital == true }
        
        if digitalNotices.count > 0 {
			let digitalSection = SectionDataModel(model: (digital: true, headerView: submitNoticeHeader), items: digitalNotices)
			sections.append(digitalSection)
		}
		
		let notices = advisories
			.filter { $0.requirements?.notice?.digital == false }
			.flatMap { $0 }
		
		if notices.count > 0 {
			let section = SectionDataModel(model: (digital: false, headerView: noticeUnavailableHeader), items: notices)
			sections.append(section)
        }
		
		Observable
			.just(sections)
			.bindTo(tableView.rx.items(dataSource: dataSource))
			.disposed(by: disposeBag)
		
		tableView.rx.setDelegate(self)
		
		dataSource.configureCell = { datasource, tableView, indexPath, advisory in
			let cell: AirMapFlightNoticeCell!
			let notice = datasource.sectionModels[indexPath.section].model
			if notice.digital {
				cell = tableView.dequeueReusableCell(withIdentifier: "noticeCell") as! AirMapFlightNoticeCell
			} else {
				cell = tableView.dequeueReusableCell(withIdentifier: "noticePhoneNumberCell") as! AirMapFlightNoticeCell			}
			cell.advisory = advisory
            return cell
		}
        
        navigationController!.flight.value.notify = true
	}
	
	@IBAction func unwindToFlightNotice(_ segue: UIStoryboardSegue) {
		
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "modalVerifyId" {
			let nav = segue.destination as! AirMapPhoneVerificationNavController
			nav.phoneVerificationDelegate = self
			let phoneVC = nav.viewControllers.first as! AirMapPhoneVerificationViewController
			phoneVC.pilot = navigationController!.flight.value.pilot
		}
	}
	
	override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
		
		if identifier == "pushReview" {
			trackEvent(.tap, label: "Review Button")
			let verified = navigationController!.flight.value.pilot!.phoneVerified
			let submitDigitalNotice = true//submitNoticeSwitch.on
			if verified {
				return true
			} else if submitDigitalNotice && !verified {
				performSegue(withIdentifier: "modalVerifyId", sender: self)
				return false
			}
		}
		return true
	}
}

extension AirMapFlightNoticeViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return dataSource.sectionModels[section].model.headerView
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return dataSource.sectionModels[section].model.headerView?.frame.height ?? 0
	}

}

extension AirMapFlightNoticeViewController: AirMapPhoneVerificationDelegate {
	
	func phoneVerificationDidVerifyPhoneNumber() {
		dismiss(animated: true) {
			self.navigationController?.flight.value.pilot?.phoneVerified = true
			self.performSegue(withIdentifier: "pushReview", sender: self)
		}
	}
}
