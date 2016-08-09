//
//  AirMapReviewFlightDetailsViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/25/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

class AirMapReviewFlightDetailsViewController: UIViewController {
	
	static let dateFormatter: NSDateFormatter = {
		$0.dateStyle = .MediumStyle
		$0.timeStyle = .ShortStyle
		return $0
	}(NSDateFormatter())
	
	@IBOutlet var tableView: UITableView!
	
	var flight: Variable<AirMapFlight>!

	private typealias SectionData = String
	private typealias RowData = (name: String, value: String?)

	private let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<SectionData,RowData>>()
	private let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()

		setupTable()
		setupBindings()
	}
	
	private func setupBindings() {
		flight.asObservable()
			.map(unowned(self, AirMapReviewFlightDetailsViewController.tableDataFromFlight))
			.bindTo(tableView.rx_itemsWithDataSource(dataSource))
			.addDisposableTo(disposeBag)
	}
	
	private func setupTable() {
		dataSource.configureCell = { [unowned self] dataSource, tableView, indexPath, rowData in
			switch rowData.name {
			case "Public":
				return tableView.dequeueReusableCellWithIdentifier("airMapCell", forIndexPath: indexPath)
			case "Aircraft":
				let cell = tableView.dequeueReusableCellWithIdentifier("aircraftCell", forIndexPath: indexPath)
				let aircraft = self.flight.value.aircraft!
				cell.textLabel?.text = aircraft.nickname
				cell.detailTextLabel?.text = [aircraft.model.manufacturer.name, aircraft.model.name].flatMap{$0}.joinWithSeparator(" ")
				return cell
			default:
				let cell = tableView.dequeueReusableCellWithIdentifier("flightDetailsCell", forIndexPath: indexPath)
				cell.textLabel?.text = rowData.name
				cell.detailTextLabel?.text = rowData.value
				return cell
			}
		}
		dataSource.titleForHeaderInSection = { [weak self] indexPath in
			self?.dataSource.sectionAtIndex(indexPath.section).identity
		}
	}
	
	private func tableDataFromFlight(flight: AirMapFlight) -> [SectionModel<SectionData,RowData>] {
		
		var sections = [SectionModel<SectionData,RowData>]()

		let df = AirMapReviewFlightDetailsViewController.dateFormatter
		
		let radius = Int(flight.buffer! / UIConstants.metersPerFoot).description + "ft"
		let altitude = Int(flight.maxAltitude! / UIConstants.metersPerFoot).description + "ft"
		let startTime = flight.startTime == nil ? "Now" : df.stringFromDate(flight.startTime!)
		let endTime = flight.endTime == nil ? (nil as String?) : df.stringFromDate(flight.endTime!)
		
		let items: [RowData] = [
			("Radius", radius),
			("Altitude", altitude),
			("Starts", startTime),
			("Ends", endTime)
			].filter { $0.value != nil }

		let detailsSection = SectionModel(model: "Details", items: items)
		sections.append(detailsSection)
		
		if let aircraft = flight.aircraft {
			let items = [RowData("Aircraft", aircraft.nickname)]
			let aircraftSection = SectionModel(model: "Aircraft", items: items)
			sections.append(aircraftSection)
		}

		if flight.isPublic {
			let items = [RowData("Public", "Yes")]
			let socialSection = SectionModel(model: "Share My Flight", items: items)
			sections.append(socialSection)
		}
		
		return sections
	}
	
}
