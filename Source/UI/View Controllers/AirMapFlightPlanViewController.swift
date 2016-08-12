//
//  AirMapFlightPlanViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/18/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Mapbox
import RxSwift
import RxCocoa
import RxDataSources
import RxSwiftExt

protocol TableRow {}

protocol TableSection {
	var title: String? { get }
	var rows: [TableRow] { get }
}

struct DataSection: TableSection {
	var title: String?
	var rows: [TableRow]
}

struct AssociatedObjectsSection: TableSection {
	var title: String?
	var rows: [TableRow]
}

struct SocialSection: TableSection {
	var title: String?
	var rows: [TableRow]
}

struct FlightPlanDataTableRow<T>: TableRow {
	typealias ValueType = T
	var title: Variable<String>
	var value: Variable<T>
	var values: [(title: String, value: Double)]?
}

struct AssociatedPilotModelRow: TableRow {
	var title: Variable<String>
	var value: Variable<AirMapPilot?>
}

struct AssociatedAircraftModelRow: TableRow {
	var title: Variable<String>
	var value: Variable<AirMapAircraft?>
}

struct SocialSharingRow: TableRow {
	var logo: UIImage
	var value: Variable<Bool>
}

class AirMapFlightPlanViewController: UIViewController {

	var location: Variable<CLLocationCoordinate2D>!

	@IBOutlet weak var mapView: AirMapMapView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var nextButton: UIButton!
	@IBOutlet weak var mapViewHeightConstraint: NSLayoutConstraint!

	private let buffer   = Variable(UIConstants.defaultBufferPreset.value)
	private let altitude = Variable(UIConstants.defaultAltitudePreset.value)
	private var startsAt = Variable(nil as NSDate?)
	private let duration = Variable(UIConstants.defaultDurationPreset.value)
	private let pilot    = Variable(nil as AirMapPilot?)
	private let aircraft = Variable(nil as AirMapAircraft?)

	private let mapViewDelegate = AirMapMapboxMapViewDelegate()
	private var sections = [TableSection]()
	private let disposeBag = DisposeBag()

	override var navigationController: AirMapFlightPlanNavigationController? {
		return super.navigationController as? AirMapFlightPlanNavigationController
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
			
		mapView.addAnnotation(navigationController!.flight.value)
		mapView.delegate = mapViewDelegate

		setupTable()
		setupBindings()
		
		AirMap.rx_getAuthenticatedPilot()
			.asOptional()
			.bindTo(pilot)
			.addDisposableTo(disposeBag)
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		guard let identifier = segue.identifier else { return }

		switch identifier {

		case "modalAircraft":
			let cell = sender as! AirMapFlightAircraftCell
			let nav = segue.destinationViewController as! UINavigationController
			let aircraftVC = nav.viewControllers.last as! AirMapAircraftViewController
			let selectedAircraft = aircraftVC.selectedAircraft.asObservable()
			selectedAircraft.delaySubscription(1.0, scheduler: MainScheduler.instance).bindTo(cell.aircraft).addDisposableTo(disposeBag)
			selectedAircraft.bindTo(aircraft).addDisposableTo(disposeBag)
			aircraftVC.selectedAircraft.value = aircraft.value

		case "modalProfile":
			let nav = segue.destinationViewController as! UINavigationController
			let profileVC = nav.viewControllers.last as! AirMapPilotProfileViewController
			profileVC.pilot = pilot

		default:
			break
		}
	}

	@IBAction func unwindToFlightPlan(segue: UIStoryboardSegue) { /* unwind segue hook; keep */ }

	private func setupTable() {
		
		let flightDataSection =  DataSection(title: nil, rows: [
			FlightPlanDataTableRow(title: Variable("Flight Radius"), value: buffer, values: UIConstants.bufferPresets),
			FlightPlanDataTableRow(title: Variable("Altitude"), value: altitude, values: UIConstants.altitudePresets),
			FlightPlanDataTableRow(title: Variable("Duration"), value: duration, values: UIConstants.durationPresets),
			FlightPlanDataTableRow(title: Variable("Starts"), value: startsAt, values: nil)
			])
		sections.append(flightDataSection)

		let associatedModels = AssociatedObjectsSection(title: "Pilot & Aircraft", rows: [
			AssociatedPilotModelRow(title: Variable("Select Pilot Profile"), value: pilot),
			AssociatedAircraftModelRow(title: Variable("Select Aircraft"), value: aircraft)
			]
		)
		sections.append(associatedModels)

		let bundle = NSBundle(forClass: self.dynamicType)
		let image = UIImage(named: "airmap_share_logo", inBundle: bundle, compatibleWithTraitCollection: nil)

		let shareSection = SocialSection(title: "Share My Flight", rows: [
			SocialSharingRow(logo: image!, value: navigationController!.shareFlight)
			])
		sections.append(shareSection)
	}

	private func setupBindings() {

		let flight = navigationController!.flight
		let status = navigationController!.status
		let shareFlight = navigationController!.shareFlight
		let requiredPermits = navigationController!.requiredPermits

		let bufferObsl = buffer.asObservable().throttle(0.3, scheduler: MainScheduler.instance).distinctUntilChanged()
		let locationBufferObsl = Observable.combineLatest(location.asObservable(), bufferObsl) { ($0, $1) }

		buffer.asObservable().distinct()
			.subscribeNext { flight.value.buffer = $0 }
			.addDisposableTo(disposeBag)

		altitude.asObservable()
			.subscribeNext { flight.value.maxAltitude = $0 }
			.addDisposableTo(disposeBag)

		aircraft.asObservable()
			.subscribeNext { flight.value.aircraft = $0 }
			.addDisposableTo(disposeBag)

		pilot.asObservable()
			.unwrap()
			.subscribeNext { flight.value.pilotId = $0.pilotId }
			.addDisposableTo(disposeBag)

		status.asObservable()
			.map { $0 != nil}
			.bindTo(nextButton.rx_enabled)
			.addDisposableTo(disposeBag)
		
		status.asObservable()
			.doOnNext{ self.mapViewDelegate.status = $0 }
			.map {
				let advisories = $0?.advisories ?? []
				let requirements = advisories.map { $0.requirements }.flatMap { $0 }
				let hasNextSteps = requirements.count > 0
				return hasNextSteps ? "Next" : "Save"
			}
			.subscribeNext { [unowned self] title in
				self.nextButton.setTitle(title, forState: .Normal)
			}
			.addDisposableTo(disposeBag)
		
		status.asObservable()
			.unwrap()
			.map { $0.advisories
				// Bind all required permits
				.map { $0.requirements?.permitsAvailable }
				.flatMap { $0 }
				.flatMap { $0 } ?? []
			}
			.bindTo(requiredPermits)
			.addDisposableTo(disposeBag)

		locationBufferObsl
			.doOnNext { location, buffer in
				flight.value.coordinate = location
				flight.value.buffer = buffer
			}
			.flatMap { AirMap.rx_checkCoordinate($0, buffer: $1) }
			.asOptional()
			.bindTo(status)
			.addDisposableTo(disposeBag)
		
		Observable.combineLatest(locationBufferObsl, status.asObservable()) { ($0, $1).0 }
			.subscribeNext(unowned(self, AirMapFlightPlanViewController.updateMapAnnotations))
			.addDisposableTo(disposeBag)
		
		shareFlight.asObservable()
			.subscribeNext { flight.value.isPublic = $0 }
			.addDisposableTo(disposeBag)
		
		tableView.rx_itemSelected.subscribeNext { [unowned self] indexPath in
			self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
			self.tableView.cellForRowAtIndexPath(indexPath)?.becomeFirstResponder()
			}
			.addDisposableTo(disposeBag)
		
		Observable.combineLatest(startsAt.asObservable(), duration.asObservable()) { ($0, $1)}
			.subscribeNext { start, duration in
				flight.value.startTime = start
				flight.value.endTime = start?.dateByAddingTimeInterval(duration)
			}
			.addDisposableTo(disposeBag)
		}
	
	func updateMapAnnotations(location: CLLocationCoordinate2D, buffer: CLLocationDistance) {

		mapView.centerCoordinate = location
		mapView.annotations?.forEach { mapView.removeAnnotation($0) }
		
		let polygon = AirMapFlightRadiusAnnotation.polygon(location, radius: buffer)
		mapView.addAnnotation(polygon)
		mapView.addAnnotation(navigationController!.flight.value)
		
		let insets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
		mapView.showAnnotations([polygon], edgePadding: insets, animated: false)
	}

	@IBAction func next() {
		
		let status = navigationController!.status.value!
		
		if status.numberOfRequiredPermits > 0 {
			performSegueWithIdentifier("pushPermits", sender: self)
		} else if status.numberOfNoticesRequired > 0 {
			performSegueWithIdentifier("pushNotices", sender: self)
		} else {
			AirMap.rx_createFlight(navigationController!.flight.value)
				.doOnError { [weak self] error in
					self?.navigationController!.flightPlanDelegate.airMapFlightPlanDidEncounter(error as NSError)
				}
				.subscribeNext { [weak self] flight in
					self?.navigationController!.flightPlanDelegate.airMapFlightPlanDidCreate(flight)
				}
				.addDisposableTo(disposeBag)
		}
	}
	
	@IBAction func maximize(button: UIButton) {
		
		mapViewHeightConstraint.constant = button.selected ? 120 : 120 + tableView.frame.height
		button.selected = !button.selected
		UIView.animateWithDuration(0.4, delay: 0, options: [.BeginFromCurrentState, .AllowUserInteraction], animations: view.layoutIfNeeded, completion: nil)
		let annotationInsets = UIEdgeInsets(top: 10, left: 50, bottom: 10, right: 50)
		mapView.showAnnotations(mapView.annotations!, edgePadding: annotationInsets, animated: true)
	}
	
	@IBAction func dismiss() {
		dismissViewControllerAnimated(true, completion: nil)
	}
}

extension AirMapFlightPlanViewController: UITableViewDataSource, UITableViewDelegate {

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return sections.count
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sections[section].rows.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

		let section = sections[indexPath.section]
		let row = section.rows[indexPath.row]

		switch section {

		case is DataSection:
			
			switch row {
				
			case let doubleRow as FlightPlanDataTableRow<Double>:
				let cell = tableView.dequeueReusableCellWithIdentifier("flightDataCell", forIndexPath: indexPath) as! AirMapFlightDataCell
				cell.model = doubleRow
				return cell
				
			case let dateRow as FlightPlanDataTableRow<NSDate?>:
				let cell = tableView.dequeueReusableCellWithIdentifier("startsAtCell", forIndexPath: indexPath) as! AirMapFlightDataDateCell
				cell.model = dateRow
				return cell
				
			default:
				fatalError()
			}

		case is AssociatedObjectsSection:

			switch row {

			case is AssociatedPilotModelRow:
				let cell = tableView.dequeueCell(at: indexPath) as AirMapFlightPilotCell
				cell.pilot = pilot
				return cell

			case is AssociatedAircraftModelRow:
				let cell = tableView.dequeueCell(at: indexPath) as AirMapFlightAircraftCell
				cell.aircraft.asObservable().bindTo(aircraft).addDisposableTo(disposeBag)
				return cell

			default:
				fatalError()
			}

		case is SocialSection:
			let cell = tableView.dequeueCell(at: indexPath) as AirMapFlightSocialCell
			let row = row as! SocialSharingRow
			cell.model = row
			cell.toggle.rx_value.asObservable().bindTo(row.value).addDisposableTo(disposeBag)
			return cell

		default:
			fatalError()
		}
	}

	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return sections[section].title == nil ? 0 : 25
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sections[section].title
	}
	
}
