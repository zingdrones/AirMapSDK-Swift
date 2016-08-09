//
//  AirMapAircraftModelViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/27/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class AirMapAircraftModelViewController: UITableViewController {
	
	var manufacturer: AirMapAircraftManufacturer!
	
	private let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.dataSource = nil
		
		AirMap
			.rx_listModels()
			.map { [unowned self] models in
				models.filter { $0.manufacturer.id == self.manufacturer.id }.sort {$0.name < $1.name }
			}
			.bindTo(tableView.rx_itemsWithCellIdentifier("Cell")) { index, model, cell in
				cell.textLabel?.text = model.name
			}
			.addDisposableTo(disposeBag)
		
		tableView.rx_itemSelected
			.map(tableView.rx_modelAtIndexPath)
			.subscribeNext(unowned(self, AirMapAircraftModelViewController.notifyDelegateOfSelection))
			.addDisposableTo(disposeBag)
	}
	
	private func notifyDelegateOfSelection(model: AirMapAircraftModel) {
		let nav = navigationController as! AirMapAircraftModelNavController
		nav.aircraftModelSelectionDelegate?.didSelectAircraftModel(model)
	}
	
}
