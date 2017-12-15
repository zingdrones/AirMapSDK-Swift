//
//  AirMapAircraftModelViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/27/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class AirMapAircraftModelViewController: UITableViewController, AnalyticsTrackable {
	
	var screenName = "Create Aircraft - Models"
	
	var manufacturer: AirMapAircraftManufacturer!
	
	fileprivate let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.dataSource = nil
		
		AirMap
			.rx.listModels(by: manufacturer.id)
			.map { models in
				models.sorted { $0.name < $1.name }
			}
			.bind(to: tableView.rx.items(cellIdentifier: "Cell")) { index, model, cell in
				cell.textLabel?.text = model.name
			}
			.disposed(by: disposeBag)
		
		tableView.rx.itemSelected
			.map(tableView.rx.model)
			.subscribeNext(weak: self, AirMapAircraftModelViewController.notifyDelegateOfSelection)
			.disposed(by: disposeBag)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		trackView()
	}
	
	fileprivate func notifyDelegateOfSelection(_ model: AirMapAircraftModel) {
		
		trackEvent(.tap, label: "Select Model")
		let nav = navigationController as! AirMapAircraftModelNavController
		nav.aircraftModelSelectionDelegate?.didSelectAircraftModel(model)
	}
	
}
