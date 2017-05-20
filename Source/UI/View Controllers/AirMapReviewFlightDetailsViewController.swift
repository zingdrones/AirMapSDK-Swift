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
			.bind(to: tableView.rx.items(dataSource: dataSource))
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
		
		let localized = LocalizedStrings.ReviewFlightPlanDetails.self
		var sections = [SectionModel<SectionData,RowData>]()

		let df = dateFormatter
		
		let radius: String
		let altitude: String

		switch AirMap.configuration.distanceUnits {
		case .metric:
			radius = UIConstants.flightDistanceFormatter.string(fromValue: flight.buffer!, unit: .meter)
			altitude = UIConstants.flightDistanceFormatter.string(fromValue: flight.maxAltitude!, unit: .meter)
		case .imperial:
			let radiusFeet = flight.buffer!.feet
			radius = UIConstants.flightDistanceFormatter.string(fromValue: radiusFeet, unit: .foot)
			let altitudeFeet = flight.maxAltitude!.feet
			altitude = UIConstants.flightDistanceFormatter.string(fromValue: altitudeFeet, unit: .foot)
		}
		
		let startTime = flight.startTime == nil ? localized.startTimeNow : df.string(from: flight.startTime!)
		let endTime = flight.endTime == nil ? (nil as String?) : df.string(from: flight.endTime!)
		let duration = UIConstants.flightDurationFormatter.string(from: flight.duration)
		
		let items: [RowData] = [
			
			(localized.rowTitleRadius,   radius),
			(localized.rowTitleAltitude, altitude),
			(localized.rowTitleStarts,   startTime),
			(localized.rowTitleEnds,     endTime),
			(localized.rowTitleDuration, duration)
			
			].filter { $0.value != nil }

		let detailsSection = SectionModel(model: localized.sectionHeaderDetails, items: items)
		sections.append(detailsSection)
		
		if let aircraft = flight.aircraft, aircraft.id != nil {
			let items = [RowData(localized.rowLabelAircraft, aircraft.nickname)]
			let aircraftSection = SectionModel(model: localized.sectionHeaderAircraft, items: items)
			sections.append(aircraftSection)
		}

		if flight.isPublic {
			
			let items = [RowData(localized.rowTitlePublic, localized.yes)]
			let socialSection = SectionModel(model: localized.sectionHeaderSocial, items: items)
			
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
