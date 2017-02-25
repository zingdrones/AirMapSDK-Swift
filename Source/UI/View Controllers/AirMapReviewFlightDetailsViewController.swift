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
		case .metric:
			radius = UIConstants.flightDistanceFormatter.string(fromValue: flight.buffer!, unit: .meter)
			altitude = UIConstants.flightDistanceFormatter.string(fromValue: flight.maxAltitude!, unit: .meter)
		case .imperial:
			let radiusFeet = flight.buffer! / DistanceUnits.metersPerFoot
			radius = UIConstants.flightDistanceFormatter.string(fromValue: radiusFeet, unit: .foot)
			let altitudeFeet = flight.maxAltitude! / DistanceUnits.metersPerFoot
			altitude = UIConstants.flightDistanceFormatter.string(fromValue: altitudeFeet, unit: .foot)
		}
		
		let now = NSLocalizedString("REVIEW_START_NOW", bundle: AirMapBundle.core, value: "Now", comment: "Time for flights that start immediately")
		let startTime = flight.startTime == nil ? now : df.string(from: flight.startTime!)
		let endTime = flight.endTime == nil ? (nil as String?) : df.string(from: flight.endTime!)
		let duration = UIConstants.flightDurationFormatter.string(from: flight.duration)
		
		
		let radiusLabel = NSLocalizedString("REVIEW_FLIGHT_RADIUS", bundle: AirMapBundle.core, value: "Radius", comment: "Label for the Buffer or radius surrounding a point or path")
		let altitudeLabel = NSLocalizedString("REVIEW_FLIGHT_ALTITUDE", bundle: AirMapBundle.core, value: "Altitude", comment: "Label for the maximum altitude for a flight")
		let startsLabel = NSLocalizedString("REVIEW_FLIGHT_STARTS", bundle: AirMapBundle.core, value: "Starts", comment: "Label for a flight's start time")
		let endsLabel = NSLocalizedString("REVIEW_FLIGHT_ENDS", bundle: AirMapBundle.core, value: "Ends", comment: "Label for a flight's end time")
		let durationLabel = NSLocalizedString("REVIEW_FLIGHT_DURATION", bundle: AirMapBundle.core, value: "Ends", comment: "Label for a flight's duration")
		
		let items: [RowData] = [
			(radiusLabel, radius),
			(altitudeLabel, altitude),
			(startsLabel, startTime),
			(endsLabel, endTime),
			(durationLabel, duration)
			].filter { $0.value != nil }

		let detailsSectionTitle = NSLocalizedString("REVIEW_FLIGHT_SECTION_TITLE_DETAILS", bundle: AirMapBundle.core, value: "Details", comment: "Header label for the flight review details section")
		let detailsSection = SectionModel(model: detailsSectionTitle, items: items)
		sections.append(detailsSection)
		
		if let aircraft = flight.aircraft, aircraft.aircraftId != nil {
			let aircraftRowLabel = NSLocalizedString("REVIEW_FLIGHT_ROW_LABEL_AIRCRAFT", bundle: AirMapBundle.core, value: "Aircraft", comment: "Label for the aircraft row")
			let items = [RowData(aircraftRowLabel, aircraft.nickname)]
			let aircraftSectionLabel = NSLocalizedString("REVIEW_FLIGHT_SECTION_TITLE_AIRCRAFT", bundle: AirMapBundle.core, value: "Aircraft", comment: "Header label for the flight review aircraft section")
			let aircraftSection = SectionModel(model: aircraftSectionLabel, items: items)
			sections.append(aircraftSection)
		}

		if flight.isPublic {
			
			let publicRowLabel = NSLocalizedString("REVIEW_FLIGHT_ROW_LABEL_PUBLIC", bundle: AirMapBundle.core, value: "Public", comment: "Label for the flight review 'is public' row")
			let yes = NSLocalizedString("REVIEW_FLIGHT_ROW_LABEL_PUBLIC_TRUE_VALUE", bundle: AirMapBundle.core, value: "Yes", comment: "'Yes' Value for the public flight row")

			let items = [RowData(publicRowLabel, yes)]
			
			let socialSectionLabel = NSLocalizedString("REVIEW_FLIGHT_SECTION_TITLE_SOCIAL", bundle: AirMapBundle.core, value: "Share My Flight", comment: "Header label for the flight review social sharing section")
			let socialSection = SectionModel(model: socialSectionLabel, items: items)
			
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
