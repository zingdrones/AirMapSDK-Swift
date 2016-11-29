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

class AirMapAdvisoriesViewController: UITableViewController {
	
	var status: Variable<AirMapStatus>!
    weak var delegate: AirMapAdvisoriesViewControllerDelegate?
	
	private typealias AdvisoriesSectionModel = SectionModel<AirMapStatus.StatusColor, AirMapStatusAdvisory>
	private let dataSource = RxTableViewSectionedReloadDataSource<AdvisoriesSectionModel>()
	private let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupTable()
		setupBindings()
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
			case .Airport?:
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
		
		tableView.rx_itemSelected
			.map(tableView.rx_modelAtIndexPath)
			.subscribeNext { [unowned self] (advisory: AirMapStatusAdvisory) in
				
				if let url = advisory.tfrProperties?.url {
					self.openWebView(url)
				}
				
				if let indexPath = self.tableView.indexPathForSelectedRow {
					self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
				}
			}
			.addDisposableTo(disposeBag)
	}
	
	private func sectionModel(status: AirMapStatus) -> [AdvisoriesSectionModel] {
		
		return AirMapStatus.StatusColor.allColors
			.map { color in
                AdvisoriesSectionModel(model: color, items: status.advisories.filter { $0.color == color })
            }
			.filter { section in
                section.items.count > 0
            }
	}
    
    @IBAction func dismiss(sender: AnyObject) {
        delegate?.advisoriesViewControllerDidTapDismissButton()
    }
    
    /**
     
     Opens a SFSafariViewController or MobileSafari
     
     - parameter url:String
     - returns: Void
     */
    
    func openWebView(url:String) {
       
        if let nsurl = NSURL(string: url) {
            if #available(iOS 9.0, *) {
                let svc = SFSafariViewController(URL: nsurl)
                svc.view.tintColor = UIColor.airMapLightBlue()
                self.presentViewController(svc, animated: true, completion: nil)
            } else {
               UIApplication.sharedApplication().openURL(nsurl)
            }
        }
    }
	
}
