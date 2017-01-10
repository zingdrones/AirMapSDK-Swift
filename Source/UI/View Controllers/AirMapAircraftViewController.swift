//
//  AirMapAircraftViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/18/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class AirMapAircraftViewController: UITableViewController, AnalyticsTrackable {
	
	var screenName = "List Aircraft"
	
	let selectedAircraft = Variable(nil as AirMapAircraft?)
	
	private let activityIndicator = ActivityIndicator()
	private let aircraft = Variable([AirMapAircraft]())
	private let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupBindings()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		trackView()
		
		AirMap
			.rx_listAircraft()
			.trackActivity(activityIndicator)
			.bindTo(aircraft)
			.addDisposableTo(disposeBag)
	}
	
	@IBAction func dismiss() {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	private func setupBindings() {
	
		tableView.dataSource = nil
		tableView.delegate = nil
		
		aircraft
			.asObservable()
			.bindTo(tableView.rx_itemsWithCellIdentifier("aircraftCell")) {
				(index, aircraft, cell) in
				cell.textLabel?.text = aircraft.nickname
				cell.detailTextLabel?.text = [aircraft.model.manufacturer.name, aircraft.model.name]
					.flatMap {$0}.joinWithSeparator(" ")
			}
			.addDisposableTo(disposeBag)
		
		tableView
			.rx_modelSelected(AirMapAircraft)
			.doOnNext { [weak self] _ in
				self?.dismissViewControllerAnimated(true, completion: nil)
			}
			.asOptional()
			.bindTo(selectedAircraft)
			.addDisposableTo(disposeBag)
		
		tableView
			.rx_itemDeleted
			.doOnNext { [unowned self] _ in
				self.trackEvent(.swipe, label: "Delete")
			}
			.map(tableView.rx_modelAtIndexPath)
			.flatMap { aircraft in
				AirMap.rx_deleteAircraft(aircraft)
					.doOnError { [unowned self] error in
						self.trackEvent(.delete, label: "Error", value: (error as NSError).code)
					}
					.doOnCompleted { [unowned self] _ in
						self.trackEvent(.delete, label: "Success")
					}
			}
			.flatMap(AirMap.rx_listAircraft)
			.doOnError { AirMap.logger.error($0) }
			.ignoreErrors()
			.bindTo(aircraft)
			.addDisposableTo(disposeBag)
		
		activityIndicator.asObservable()
			.throttle(0.25, scheduler: MainScheduler.instance)
			.distinctUntilChanged()
			.bindTo(rx_loading)
			.addDisposableTo(disposeBag)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		guard let identifier = segue.identifier else { return }
		
		switch identifier {
			
		case "createAircraft":
			trackEvent(.tap, label: "New Aircraft Button")
			let nav = segue.destinationViewController as! AirMapAircraftNavController
			nav.aircraftDelegate = self
			
		case "editAircraft":
			trackEvent(.tap, label: "Edit Aircraft Button")
			let cell = sender as! UITableViewCell
			let indexPath = tableView.indexPathForCell(cell)!
			let aircraft = try! tableView.rx_modelAtIndexPath(indexPath) as AirMapAircraft
			let nav = segue.destinationViewController as! AirMapAircraftNavController
			nav.aircraftDelegate = self
			let aircraftVC = nav.viewControllers.last as! AirMapCreateAircraftViewController
			aircraftVC.aircraft = aircraft
			
		default:
			break
		}
	}
	
	@IBAction func unwindToAircraft(segue: UIStoryboardSegue) { /* unwind hook; keep */ }
}

extension AirMapAircraftViewController: AirMapAircraftNavControllerDelegate {
	
	func aircraftNavController(navController: AirMapAircraftNavController, didCreateOrModify aircraft: AirMapAircraft) {
		selectedAircraft.value = aircraft
		navigationController?.dismissViewControllerAnimated(true, completion: nil)
	}
}
