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
	
	fileprivate let dateFormatter: DateFormatter = {
		$0.dateStyle = .medium
		$0.timeStyle = .short
		return $0
	}(DateFormatter())
	
	fileprivate let durationFormatter: DateComponentsFormatter = {
		$0.allowedUnits = [.hour, .minute]
		$0.zeroFormattingBehavior = .dropAll
		$0.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
		$0.allowsFractionalUnits = false
		$0.unitsStyle = .full
		return $0
	}(DateComponentsFormatter())
	
	@IBOutlet var tableView: UITableView!
	
	var flight: Variable<AirMapFlight>!

	fileprivate typealias SectionData = String
	fileprivate typealias RowData = (name: String, value: String?)

	fileprivate let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<SectionData,RowData>>()
	fileprivate let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()

		setupTable()
		setupBindings()
	}
	
	fileprivate func setupBindings() {
		flight?.asObservable()
			.map(unowned(self, AirMapReviewFlightDetailsViewController.tableDataFromFlight))
			.bindTo(tableView.rx.items(dataSource: dataSource))
			.disposed(by: disposeBag)
	}
	
	fileprivate func setupTable() {
		dataSource.configureCell = { [unowned self] dataSource, tableView, indexPath, rowData in
			switch rowData.name {
			case "Public":
				return tableView.dequeueReusableCell(withIdentifier: "airMapCell", for: indexPath)
			case "Aircraft":
				let cell = tableView.dequeueReusableCell(withIdentifier: "aircraftCell", for: indexPath)
				let aircraft = self.flight.value.aircraft!
				cell.textLabel?.text = aircraft.nickname
				cell.detailTextLabel?.text = [aircraft.model.manufacturer.name, aircraft.model.name].flatMap{$0}.joined(separator: " ")
				return cell
			default:
				let cell = tableView.dequeueReusableCell(withIdentifier: "flightDetailsCell", for: indexPath)
				cell.textLabel?.text = rowData.name
				cell.detailTextLabel?.text = rowData.value
				return cell
			}
		}
		
		dataSource.titleForHeaderInSection = { dataSource, index in
			dataSource.sectionModels[index].identity
		}
	}
	
	fileprivate func tableDataFromFlight(_ flight: AirMapFlight) -> [SectionModel<SectionData,RowData>] {
		
		var sections = [SectionModel<SectionData,RowData>]()

		let df = dateFormatter
		
		let radius: String
		let altitude: String

		switch AirMap.configuration.distanceUnits {
		case .feet:
			radius = Int(flight.buffer! / UIConstants.metersPerFoot).description + " ft"
			altitude = Int(flight.maxAltitude! / UIConstants.metersPerFoot).description + " ft"
		case .meters:
			radius = Int(flight.buffer!).description + " m"
			altitude = Int(flight.maxAltitude!).description + " m"
		}
		
		let startTime = flight.startTime == nil ? "Now" : df.string(from: flight.startTime!)
		let endTime = flight.endTime == nil ? (nil as String?) : df.string(from: flight.endTime!)
		let duration = durationFormatter.string(from: flight.duration)
		
		let items: [RowData] = [
			("Radius", radius),
			("Altitude", altitude),
			("Starts", startTime),
			("Ends", endTime),
			("Duration", duration)
			].filter { $0.value != nil }

		let detailsSection = SectionModel(model: "Details", items: items)
		sections.append(detailsSection)
		
		if let aircraft = flight.aircraft, aircraft.aircraftId != nil {
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
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "modalFAQ" {
			let nav = segue.destination as! UINavigationController
			let faqVC = nav.viewControllers.last as! AirMapFAQViewController
			faqVC.section = .LetOthersKnow
		}
	}
	
}
