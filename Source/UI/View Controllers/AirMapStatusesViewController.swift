//
//  AirMapStatusesViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/18/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class AirMapStatusesViewController: UITableViewController {

	var flight: Variable<AirMapFlight>! {
		didSet { setupBindings() }
	}
	
	fileprivate let disposeBag = DisposeBag()
	
	fileprivate func setupBindings() {
		
		tableView.dataSource = nil
		tableView.delegate = nil
		
		flight?.asObservable()
			.map { $0.statuses }
			.bindTo(tableView.rx.items(cellIdentifier: "StatusCell")) { index, status, cell in

				// TODO: Replace with authority_name once provided by API
				let nameComponents = status.managerId.components(separatedBy: "|")
				if nameComponents.count == 2 {
					cell.textLabel?.text = nameComponents[1].uppercased()
				} else {
					cell.textLabel?.text = status.managerId
				}
				
				cell.detailTextLabel?.text = status.status.rawValue
			}
			.addDisposableTo(disposeBag)
	}
		
}
