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

class AirMapFlightNoticeViewController: UIViewController {
	
	@IBOutlet var submitNoticeHeader: UIView!
	@IBOutlet var noticeUnavailableHeader: UIView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var submitNoticeSwitch: UISwitch!
		
	override var navigationController: AirMapFlightPlanNavigationController? {
		return super.navigationController as? AirMapFlightPlanNavigationController
	}
	private typealias SectionData = (digital: Bool, headerView: UIView!)
	private typealias RowData = AirMapStatusAdvisory

	private let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<SectionData, RowData>>()
	private let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupBindings()
		tableView.estimatedRowHeight = 44
	}
	
	private func setupBindings() {
		
		let advisories = navigationController!.status.value!.advisories
		var sections = [SectionModel<SectionData, RowData>]()
		
		let digitalNotices = advisories
			.filter { $0.requirements?.notice?.digital == true }
			.flatMap { $0 }
		
		if digitalNotices.count > 0 {
			let digitalSection = SectionModel(model: (digital: true, headerView: submitNoticeHeader), items: digitalNotices)
			sections.append(digitalSection)
		}
		
		let notices = advisories
			.filter { $0.requirements?.notice?.digital == false && $0.requirements?.notice?.phoneNumber != nil }
			.flatMap { $0 }
		
		if notices.count > 0 {
			let section = SectionModel(model: (digital: false, headerView: noticeUnavailableHeader), items: notices)
			sections.append(section)
		}
		
		Observable
			.just(sections)
			.bindTo(tableView.rx_itemsWithDataSource(dataSource))
			.addDisposableTo(disposeBag)
		
		tableView.rx_setDelegate(self)
		
		dataSource.configureCell = { datasource, tableView, indexPath, advisory in
			let cell: AirMapFlightNoticeCell!
			let notice = datasource.sectionAtIndex(indexPath.section).model
			if notice.digital {
				cell = tableView.dequeueReusableCellWithIdentifier("noticeCell") as! AirMapFlightNoticeCell
			} else {
				if let phoneNumber = advisory.requirements?.notice?.phoneNumber where !phoneNumber.isEmpty {
					cell = tableView.dequeueReusableCellWithIdentifier("noticePhoneNumberCell") as! AirMapFlightNoticeCell
				} else {
					cell = tableView.dequeueReusableCellWithIdentifier("noticeCell") as! AirMapFlightNoticeCell
				}
			}
			cell.advisory = advisory
			return cell
		}
	}
	
	@IBAction func unwindToFlightNotice(segue: UIStoryboardSegue) {
		
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "modalVerifyId" {
			let nav = segue.destinationViewController as! AirMapPhoneVerificationNavController
			nav.phoneVerificationDelegate = self
			let phoneVC = nav.viewControllers.first as! AirMapPhoneVerificationViewController
			phoneVC.pilot = navigationController!.flight.value.pilot
		}
	}
	
	override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
		if identifier == "pushReview" {
			let verified = navigationController!.flight.value.pilot!.phoneVerified
			let submitDigitalNotice = submitNoticeSwitch.on
			if verified {
				return true
			} else if submitDigitalNotice && !verified {
				performSegueWithIdentifier("modalVerifyId", sender: self)
				return false
			}
		}
		return true
	}
}

extension AirMapFlightNoticeViewController: UITableViewDelegate {
	
	func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return dataSource.sectionAtIndex(section).model.headerView
	}
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return dataSource.sectionModels[section].model.headerView.frame.height
	}

}

extension AirMapFlightNoticeViewController: AirMapPhoneVerificationDelegate {
	
	func phoneVerificationDidVerifyPhoneNumber() {
		dismissViewControllerAnimated(true) {
			self.navigationController?.flight.value.pilot?.phoneVerified = true
			self.performSegueWithIdentifier("pushReview", sender: self)
		}
	}
}
