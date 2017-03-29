//
//  AirMapAircraftManufacturerViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/27/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class AirMapAircraftManufacturerViewController: UITableViewController, AnalyticsTrackable {
	
	var screenName = "Create Aircraft - Manufacturers"
	
	fileprivate let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.dataSource = nil
		
		AirMap
			.rx.listManufacturers()
			.map { $0.sorted {$0.name < $1.name } }
			.bindTo(tableView.rx.items(cellIdentifier: "Cell")) { index, manufacturer, cell in
				cell.textLabel?.text = manufacturer.name
			}
			.disposed(by: disposeBag)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		trackView()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "pushModel" {
			trackEvent(.tap, label: "Select Manufacturer")
			let cell = sender as! UITableViewCell
			let indexPath = tableView.indexPath(for: cell)!
			let modelVC = segue.destination as! AirMapAircraftModelViewController
			modelVC.manufacturer = try! tableView.rx.model(at: indexPath)
		}
	}
	
	@IBAction func cancel() {
		let nav = navigationController as! AirMapAircraftModelNavController
		nav.aircraftModelSelectionDelegate?.didSelectAircraftModel(nil)
	}
	
}
