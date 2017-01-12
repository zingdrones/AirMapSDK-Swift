//
//  AirMapAdvisoriesViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 10/25/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SafariServices

public protocol AirMapAdvisoriesViewControllerDelegate: class {
    func advisoriesViewControllerDidTapDismissButton()
}

public class AirMapAdvisoriesViewController: UITableViewController, AnalyticsTrackable {
	
	@IBOutlet var localRulesHeader: UIView!
	@IBOutlet weak var localityName: UILabel!
	
	var screenName = "Advisories"
	
	public let status = Variable(nil as AirMapStatus?)
	public let localityRules = Variable(nil as (name: String, rules: [AirMapLocalRule])?)

	weak var delegate: AirMapAdvisoriesViewControllerDelegate?
	
	private typealias AdvisoriesSectionModel = SectionModel<AirMapStatus.StatusColor, AirMapStatusAdvisory>
	private let dataSource = RxTableViewSectionedReloadDataSource<AdvisoriesSectionModel>()
	private let disposeBag = DisposeBag()
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		
		setupTable()
		setupBindings()
	}
	
	override public func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		trackView()
	}
	
	override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
		if segue.identifier == "pushLocalRules" {
			
			let rulesVC = segue.destinationViewController as! AirMapLocalRulesViewController
			rulesVC.localityRules = localityRules.value
		}
	}
	
	private func setupTable() {
		
		tableView.delegate = nil
		tableView.dataSource = nil
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 75
		
		dataSource.configureCell = { dataSource, tableView, indexPath, advisory in
			
			let identifier: String
			
			switch advisory.type {
			case .TFR?:
				identifier = "TFRCell"
			case .Wildfires?:
				identifier = "WildfireCell"
			case .Airport?, .Heliport?:
				identifier = "AirportCell"
			default:
				if advisory.organization != nil && advisory.organization!.name != advisory.name {
					identifier = "OrganizationAdvisoryCell"
				} else {
					identifier = "AdvisoryCell"
				}
			}
			
			return tableView.cellWith(advisory, at: indexPath, withIdentifier: identifier) as AirMapAdvisoryCell
		}
		
		dataSource.titleForHeaderInSection = { dataSource, section in
			dataSource.sectionAtIndex(section).model.description
		} 
	}
	
	private func setupBindings() {
		
		status.asDriver()
			.map(unowned(self, AirMapAdvisoriesViewController.sectionModel))
			.drive(tableView.rx_itemsWithDataSource(dataSource))
			.addDisposableTo(disposeBag)
		
		localityRules.asDriver()
			.map { $0?.name ?? "" }
			.drive(localityName.rx_text)
			.addDisposableTo(disposeBag)
		
		localityRules.asDriver()
			.map { $0 == nil }
			.distinctUntilChanged()
			.driveNext(unowned(self, AirMapAdvisoriesViewController.toggleHeaderVisibility))
			.addDisposableTo(disposeBag)
		
		tableView.rx_itemSelected
			.map(tableView.rx_modelAtIndexPath)
			.subscribeNext { [unowned self] (advisory: AirMapStatusAdvisory) in
				
				if let url = advisory.tfrProperties?.url {
					self.trackEvent(.tap, label: "TFR Details")
					self.openWebView(url)
				}
				
				if let indexPath = self.tableView.indexPathForSelectedRow {
					self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
				}
			}
			.addDisposableTo(disposeBag)
	}
	
	private func sectionModel(status: AirMapStatus?) -> [AdvisoriesSectionModel] {
		
		guard let status = status else { return [] }
		
		return AirMapStatus.StatusColor.allColors
			.map { color in
				(color: color, advisories: status.advisories.filter({ $0.color == color }))
			}
			.filter { $0.advisories.count > 0 }
			.map(AdvisoriesSectionModel.init)
	}
	
	private func toggleHeaderVisibility(hidden: Bool) {
		if hidden {
			tableView.tableHeaderView = nil
		} else {
			tableView.tableHeaderView = self.localRulesHeader
		}
	}
	
    @IBAction func dismiss(sender: AnyObject) {
		trackEvent(.tap, label: "Close Button")
        delegate?.advisoriesViewControllerDidTapDismissButton()
    }
	
    func openWebView(url: String) {
       
        if let nsurl = NSURL(string: url) {
            if #available(iOS 9.0, *) {
                let svc = SFSafariViewController(URL: nsurl)
                svc.view.tintColor = UIColor.airMapLightBlue()
                presentViewController(svc, animated: true, completion: nil)
            } else {
               UIApplication.sharedApplication().openURL(nsurl)
            }
        }
    }
	
}
