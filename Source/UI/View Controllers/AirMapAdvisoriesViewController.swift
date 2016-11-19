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
    var delegate:AirMapAdvisoriesViewControllerDelegate?
	
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
            
            var identifier = "AirMapAdvisoryCell"
            
            if let type = advisory.type {
                switch type {
                case AirMapAirspaceType.TFR, .Wildfires :
                    identifier = "AirMapAdvisoryTFRCell"
                    break
                case AirMapAirspaceType.Wildfires :
                    identifier = "AirMapAdvisoryWildfireCell"
                    break
                case AirMapAirspaceType.Airport :
                    identifier = "AirMapAdvisoryAirportCell"
                    break

                default:
                    break
                }
            }
           return tableView.cellWith(advisory, at: indexPath, withIdentifier: identifier) as AirMapAdvisoryCell
		}
        
        tableView.rx_itemSelected
            .map(tableView.rx_modelAtIndexPath)
            .subscribeNext {[unowned self] (advisory: AirMapStatusAdvisory) in
                
                if let url = advisory.tfrProperties?.url {
                    self.openWebView(url)
                }
                
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                }
            }
            .addDisposableTo(disposeBag)
		
		dataSource.titleForHeaderInSection = { dataSource, section in
			dataSource.sectionAtIndex(section).model.description
		} 
	}
	
	private func setupBindings() {
		
		status.asDriver()
			.map(sectionModel)
			.drive(tableView.rx_itemsWithDataSource(dataSource))
			.addDisposableTo(disposeBag)
	}
	
	private func sectionModel(status: AirMapStatus) -> [AdvisoriesSectionModel] {
		
		return AirMapStatus.StatusColor.allColors
			.map { color in
                AdvisoriesSectionModel(model: color, items: status.advisories
                    .filter { $0.color == color }
                    .flatMap { advisory in
                         if let notice = advisory.requirements?.notice?.digital {
                            if let organization = status.organizations.filter ({ $0.id == advisory.organizationId }).first {
                                advisory.organization = organization
                                advisory.requirements!.notice!.digital = true
                            }
                        }
                        return advisory
                    }
                    .filterDuplicates { (left, right) in
                        let notNil = left.organizationId != nil && right.organizationId != nil
                        return notNil && left.organizationId == right.organizationId
                    }
                )
            }.filter { section in
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
	
	deinit {
		print("deinit")
	}
}
