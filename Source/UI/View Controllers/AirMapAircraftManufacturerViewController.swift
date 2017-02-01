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
	
	private let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.dataSource = nil
		
		AirMap
			.rx_listManufacturers()
			.map { $0.sort {$0.name < $1.name } }
			.bindTo(tableView.rx_itemsWithCellIdentifier("Cell")) { index, manufacturer, cell in
				cell.textLabel?.text = manufacturer.name
			}
			.addDisposableTo(disposeBag)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		trackView()
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "pushModel" {
			trackEvent(.tap, label: "Select Manufacturer")
			let cell = sender as! UITableViewCell
			let indexPath = tableView.indexPathForCell(cell)!
			let modelVC = segue.destinationViewController as! AirMapAircraftModelViewController
			modelVC.manufacturer = try! tableView.rx_modelAtIndexPath(indexPath)
		}
	}
	
	@IBAction func cancel() {
		let nav = navigationController as! AirMapAircraftModelNavController
		nav.aircraftModelSelectionDelegate?.didSelectAircraftModel(nil)
	}
	
}
