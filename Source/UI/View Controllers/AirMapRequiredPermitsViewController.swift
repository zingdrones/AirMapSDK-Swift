//
//  AirMapRequiredPermitsViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/18/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

/// Displays a list of organizations that require a permit and selected permits for each, if any.
class AirMapRequiredPermitsViewController: UIViewController, AnalyticsTrackable {
	
	var screenName = "Create Flight - Permits"
	
	@IBOutlet weak var permitComplianceStatus: UILabel!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var nextButton: UIButton!
	
	var status: Variable<AirMapStatus?> {
		return navigationController!.status
	}
	
	override var navigationController: AirMapFlightPlanNavigationController? {
		return super.navigationController as? AirMapFlightPlanNavigationController
	}

	/// Valid permits the user already holds
	private var existingPermits: Variable<[AirMapPilotPermit]> {
		return navigationController!.existingPermits
	}
	/// Any new permits that the user is creating that they don't already hold
	private var draftPermits: Variable<[AirMapPilotPermit]> {
		return navigationController!.draftPermits
	}
	/// The permits that user has selected in order to advance to the next step of the flow
	internal var selectedPermits: Variable<[(organization: AirMapOrganization, permit: AirMapAvailablePermit, pilotPermit: AirMapPilotPermit)]> {
		return navigationController!.selectedPermits
	}

	private typealias SectionData = SectionModel<AirMapOrganization, RowData>
	private typealias RowData = (organization: AirMapOrganization, availablePermit: AirMapAvailablePermit?, pilotPermit: AirMapPilotPermit?)
	private let dataSource = RxTableViewSectionedReloadDataSource<SectionData>()
	private let activityIndicator = ActivityIndicator()
	private let disposeBag = DisposeBag()
	
	// MARK: - View Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()
		
		loadData()
		setupBindings()
		setupTableView()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		trackView()
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		guard let identifier = segue.identifier else { return }
		
		switch identifier {
			
		case "modalPermitSelection":
			let cell = sender as! UITableViewCell
			let indexPath = tableView.indexPathForCell(cell)!
			let nav = segue.destinationViewController as! UINavigationController
			let availablePermitsVC = nav.viewControllers.first as! AirMapAvailablePermitsViewController
			availablePermitsVC.status = status.value!
			availablePermitsVC.organization = dataSource.itemAtIndexPath(indexPath).organization
			availablePermitsVC.existingPermits = existingPermits.value
			availablePermitsVC.draftPermits = draftPermits.value
		case "modalFAQ" :
			let nav = segue.destinationViewController as! UINavigationController
			let faqVC = nav.viewControllers.last as! AirMapFAQViewController
			faqVC.section = .Permits
			trackEvent(.tap, label: "Info Button (Permit FAQ's)")
		default:
			break
		}
	}

	@IBAction func unwindToRequiredPermits(segue: UIStoryboardSegue) { /* Hook for Interface Builder; keep. */ }
	
	@IBAction func unwindFromPermitSelection(segue: UIStoryboardSegue) {
		
		if segue.identifier == "unwindFromNewPermitSelection" {
			
			let permitVC = segue.sourceViewController as! AirMapAvailablePermitViewController
			let availablePermit = permitVC.permit.value
			let organization = permitVC.organization
			
			// Create a new draft pilot permit from the available permit and custom properties
			let draftPermit = AirMapPilotPermit()
			draftPermit.permitId = availablePermit.id
			draftPermit.customProperties = permitVC.customProperties
			
			// If new permit doesn't already exist in drafts or existing permits, add to drafts
			let isExisting = (existingPermits.value + draftPermits.value)
				.filter { $0.permitId == draftPermit.permitId }
				.count > 0
			
			if !isExisting {
				draftPermits.value.append(draftPermit)
			}
			
			// Select permit if it isn't already selected
			let isSelected = selectedPermits.value
				.filter { $0.permit.id == draftPermit.permitId }
				.count > 0
			
			if !isSelected {
				selectedPermits.value.append((organization, availablePermit, draftPermit))
			}
			
		}
		
		tableView.reloadData()
	}
	
	// MARK: - Setup
	
	private func setupTableView() {
		
		tableView.rx_setDelegate(self)
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 75
		tableView.layoutAndResizeHeader()
		
		dataSource.configureCell = { dataSource, tableView, indexPath, rowData in
			
			if let availablePermit = rowData.availablePermit, let pilotPermit = rowData.pilotPermit {
				let cell = tableView.cellWith((availablePermit, pilotPermit), at: indexPath) as AirMapPilotPermitCell
				cell.imageView?.image = AirMapImage.image(named: "deselected_cell_option")
				cell.imageView?.highlightedImage = AirMapImage.image(named: "selected_cell_option")
				
				return cell
			} else {
				let cell = tableView.dequeueReusableCellWithIdentifier("selectADifferenrPermit", forIndexPath: indexPath)
				cell.textLabel?.text = indexPath.row == 0 ? "Select permit" : "Select a different permit"
				return cell
			}
		}
	}
	
	private func setupBindings() {
		
		Driver.combineLatest(status.asDriver(), existingPermits.asDriver(), draftPermits.asDriver(), resultSelector: unowned(self, AirMapRequiredPermitsViewController.sectionModels))
			.drive(tableView.rx_itemsWithDataSource(dataSource))
			.addDisposableTo(disposeBag)
		
		Driver.combineLatest(selectedPermits.asDriver(), status.asDriver()) { ($0, $1) }
			.doOnNext { [weak self] selected, status in
				self?.permitComplianceStatus.text = "You have selected \(selected.count) of \(status!.organizations.count) required permits"
			}
			.map { $0.count == $1?.organizations.count }
			.drive(nextButton.rx_enabled)
			.addDisposableTo(disposeBag)
		
		activityIndicator.asObservable()
			.throttle(0.25, scheduler: MainScheduler.instance)
			.distinctUntilChanged()
			.bindTo(rx_loading)
			.addDisposableTo(disposeBag)
	}
	
	private func loadData() {
		
		AirMap
			.rx_listPilotPermits()
			.trackActivity(activityIndicator)
			.map(unowned(self, AirMapRequiredPermitsViewController.filterOutInvalidPermits))
			.bindTo(existingPermits)
			.addDisposableTo(disposeBag)
	}
	
	private func filterOutInvalidPermits(permits: [AirMapPilotPermit]) -> [AirMapPilotPermit] {
		
		return permits
			// Only return available permits that are applicable and not expired
			.filter { status.value?.applicablePermits.map { $0.id }.contains($0.permitId) ?? false }
			.filter { $0.permitDetails.singleUse != true }
            .filter { ($0.expiresAt ?? NSDate.distantFuture()).greaterThanDate(NSDate()) }
			.filter { $0.status != .Rejected }
	}
	
	// MARK: - Instance Methods
	
	@IBAction func next() {

		trackEvent(.tap, label: "Next Button")

		if status.value!.supportsDigitalNotice {
			performSegueWithIdentifier("pushFlightNotice", sender: self)
		} else {
			performSegueWithIdentifier("pushReview", sender: self)
		}
	}
	
	private func sectionModels(status: AirMapStatus?, existingPermits: [AirMapPilotPermit], draftPermits: [AirMapPilotPermit]) -> [SectionData] {
		
		guard let status = status else { return [] }
		
		return status.organizations.map { organization -> SectionData in

			// Get all available permits for organization
			let availablePermits = status.advisories
				.filter { $0.organization == organization }
				.flatMap { $0.availablePermits }
			
			// Find a permit
			func availablePermit(from permit: AirMapPilotPermit) -> AirMapAvailablePermit? {
				return availablePermits.filter { $0.id == permit.permitId }.first
			}
			
			// Existing permits from the user's permit wallet
			let existingPermitRows: [RowData] = existingPermits
				.filter { availablePermits.map { $0.id }.contains($0.permitId) }
				.map { pilotPermit in (organization, availablePermit(from: pilotPermit), pilotPermit) }
			
			// All new permits that have been drafted during this flow
			let draftPermitRows: [RowData] = draftPermits
				.filter { availablePermits.map{ $0.id }.contains($0.permitId) }
				.map { pilotPermit in (organization, availablePermit(from: pilotPermit), pilotPermit) }
			
			// A new row for selecting a permit not perviously drafted or acquired
			let newPermitRow: RowData = (organization: organization, availablePermit: nil, pilotPermit: nil)
			
			return SectionData(model: organization, items: existingPermitRows + draftPermitRows + [newPermitRow])
		}
	}
	
	private func uncheckRowsInSection(section: Int) {
		for index in 0..<dataSource.sectionAtIndex(section).items.count-1 {
			let ip = NSIndexPath(forRow: index, inSection: section)
			let cell = tableView.cellForRowAtIndexPath(ip) as? AirMapPilotPermitCell
			cell?.imageView?.highlighted = false
		}
	}
	
}

extension AirMapRequiredPermitsViewController: UITableViewDelegate {
	
	func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let header = TableHeader(dataSource.sectionAtIndex(section).model.name.uppercaseString)!
		header.textLabel.font = UIFont.systemFontOfSize(17)
		return header
	}
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 45
	}
	
	func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		
		guard
			let row = try? dataSource.modelAtIndexPath(indexPath) as? RowData,
			let rowOrganization = row?.organization,
			let pilotPermit = row?.pilotPermit else { return }
		
		if selectedPermits.value.filter ({$0.pilotPermit == pilotPermit && $0.organization == rowOrganization }).first != nil {
			cell.imageView?.highlighted = true
		} else {
			cell.imageView?.highlighted = false
		}
		
		// if draft, don't show wallet icon
		let isDraft = self.draftPermits.value.contains(pilotPermit)
		(cell as! AirMapPilotPermitCell).walletIcon.hidden = isDraft
		(cell as! AirMapPilotPermitCell).walletIconSpacing.constant = isDraft ? -30 : 5
		(cell as! AirMapPilotPermitCell).setNeedsLayout()
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
				
		tableView.deselectRowAtIndexPath(indexPath, animated: false)
		
		if let model = try? dataSource.modelAtIndexPath(indexPath),
			let row = model as? RowData,
			let pilotPermit = row.pilotPermit {
			
			let cell = tableView.cellForRowAtIndexPath(indexPath)
			
			if let alreadySelectedPermit = selectedPermits.value.filter({$0.permit == pilotPermit && $0.organization == row.organization}).first {
				selectedPermits.value = selectedPermits.value.filter { $0.permit !== alreadySelectedPermit.permit }
				cell?.imageView?.highlighted = false
			} else {
				uncheckRowsInSection(indexPath.section)
				if let previousSelectedOrgPermit = selectedPermits.value.filter({$0.organization.id == row.organization.id}).first {
					selectedPermits.value = selectedPermits.value.filter { $0 != previousSelectedOrgPermit }
				}
				
				selectedPermits.value.append((organization: row.organization, permit: row.availablePermit!, pilotPermit: pilotPermit))
				cell?.imageView?.highlighted = true
				trackEvent(.tap, label: "Selected Permit")
			}
		} else {
			trackEvent(.tap, label: "Selecte a Different Permit")
		}
	}
	
}
