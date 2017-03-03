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

open class AirMapAdvisoriesViewController: UITableViewController, AnalyticsTrackable {
	
	@IBOutlet var localRulesHeader: UIView!
	@IBOutlet weak var localityName: UILabel!
	
	var screenName = "Advisories"
	
	open let status = Variable(nil as AirMapStatus?)

	weak var delegate: AirMapAdvisoriesViewControllerDelegate?
	
	fileprivate typealias AdvisoriesSectionModel = SectionModel<AirMapStatus.StatusColor, AirMapStatusAdvisory>
	fileprivate let dataSource = RxTableViewSectionedReloadDataSource<AdvisoriesSectionModel>()
	fileprivate let disposeBag = DisposeBag()
	
	override open func viewDidLoad() {
		super.viewDidLoad()
		
		setupTable()
		setupBindings()
	}
	
	override open func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		trackView()
	}
	
	fileprivate func setupTable() {
		
		tableView.delegate = nil
		tableView.dataSource = nil

		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 75
		
		dataSource.configureCell = { dataSource, tableView, indexPath, advisory in
			
			let identifier: String
			
			switch advisory.type {
			case .tfr?:
				identifier = "TFRCell"
			case .wildfire?:
				identifier = "WildfireCell"
			case .airport?, .heliport?:
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
		
		// ((TableViewSectionedDataSource<S>, Int) -> String?)?
		dataSource.titleForHeaderInSection = { dataSource, index in
			dataSource.sectionModels[index].description
		}
	
		// Reset delegate for methods declared below to be called
		tableView.rx.setDelegate(self)
	}
	
	fileprivate func setupBindings() {
		
		status.asDriver()
			.map(unowned(self, AirMapAdvisoriesViewController.sectionModel))
			.drive(tableView.rx.items(dataSource: dataSource))
			.disposed(by: disposeBag)
		
		tableView.rx.itemSelected
			.map(tableView.rx.model)
			.subscribe(onNext: { [unowned self] (advisory: AirMapStatusAdvisory) in
				
				if let url = advisory.tfrProperties?.url {
					self.trackEvent(.tap, label: "TFR Details")
					self.openWebView(url)
				}
				
				if let indexPath = self.tableView.indexPathForSelectedRow {
					self.tableView.deselectRow(at: indexPath, animated: true)
				}
			})
			.disposed(by: disposeBag)
	}
	
	fileprivate func sectionModel(_ status: AirMapStatus?) -> [AdvisoriesSectionModel] {
		
		guard let status = status else { return [] }
		
		return AirMapStatus.StatusColor.allColors
			.map { color in
				(color: color, advisories: status.advisories.filter({ $0.color == color }))
			}
			.filter { $0.advisories.count > 0 }
			.map(AdvisoriesSectionModel.init)
	}
	
    @IBAction func dismiss(_ sender: AnyObject) {
		trackEvent(.tap, label: "Close Button")
		resignFirstResponder()
        delegate?.advisoriesViewControllerDidTapDismissButton()
    }
	
    func openWebView(_ url: String) {
       
        if let nsurl = URL(string: url) {
            if #available(iOS 9.0, *) {
                let svc = SFSafariViewController(url: nsurl)
                svc.view.tintColor = .airMapLightBlue
                present(svc, animated: true, completion: nil)
            } else {
               UIApplication.shared.openURL(nsurl)
            }
        }
    }
	
	// MARK: - UITableViewDataSource
	
	open override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		let section = dataSource.sectionModels[section]
		
		let header = UIView(frame: tableView.bounds)
		header.frame.size.height = 25
		header.backgroundColor = UIColor(red: 64.0/255.0, green: 84.0/255.0, blue: 93.0/255.0, alpha: 1.0)
		
		let label = UILabel()
		label.backgroundColor = header.backgroundColor
		label.textColor = UIColor.white
		label.font = UIFont.systemFont(ofSize: 13)
		label.text = section.model.description.uppercased()
		label.frame = header.bounds.insetBy(dx: tableView.superview!.layoutMargins.left + 12, dy: 0)
		label.autoresizingMask = [.flexibleWidth, .flexibleHeight]

		header.addSubview(label)
		
		return header
	}
}
