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
	fileprivate var existingPermits: Variable<[AirMapPilotPermit]> {
		return navigationController!.existingPermits
	}
	/// Any new permits that the user is creating that they don't already hold
	fileprivate var draftPermits: Variable<[AirMapPilotPermit]> {
		return navigationController!.draftPermits
	}
	/// The permits that user has selected in order to advance to the next step of the flow
	internal var selectedPermits: Variable<[(organization: AirMapOrganization, permit: AirMapAvailablePermit, pilotPermit: AirMapPilotPermit)]> {
		return navigationController!.selectedPermits
	}

	fileprivate typealias SectionData = SectionModel<AirMapOrganization, RowData>
	fileprivate typealias RowData = (organization: AirMapOrganization, availablePermit: AirMapAvailablePermit?, pilotPermit: AirMapPilotPermit?)
	fileprivate let dataSource = RxTableViewSectionedReloadDataSource<SectionData>()
	fileprivate let activityIndicator = ActivityIndicator()
	fileprivate let disposeBag = DisposeBag()

	// MARK: - View Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()
		
		loadData()
		setupBindings()
		setupTableView()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		trackView()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let identifier = segue.identifier else { return }
		
		switch identifier {
			
		case "modalPermitSelection":
			let cell = sender as! UITableViewCell
			let indexPath = tableView.indexPath(for: cell)!
			let nav = segue.destination as! UINavigationController
			let availablePermitsVC = nav.viewControllers.first as! AirMapAvailablePermitsViewController
			availablePermitsVC.status = status.value!
			availablePermitsVC.organization = dataSource.sectionModels[indexPath.section].items[indexPath.row].organization
			availablePermitsVC.existingPermits = existingPermits.value
			availablePermitsVC.draftPermits = draftPermits.value
		case "modalFAQ" :
			let nav = segue.destination as! UINavigationController
			let faqVC = nav.viewControllers.last as! AirMapFAQViewController
			faqVC.section = .Permits
			trackEvent(.tap, label: "Info Button (Permit FAQ's)")
		default:
			break
		}
	}

	@IBAction func unwindToRequiredPermits(_ segue: UIStoryboardSegue) { /* Hook for Interface Builder; keep. */ }
	
	@IBAction func unwindFromPermitSelection(_ segue: UIStoryboardSegue) {
		
		if segue.identifier == "unwindFromNewPermitSelection" {
			
			let permitVC = segue.source as! AirMapAvailablePermitViewController
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
				selectedPermits.value.append((organization!, availablePermit, draftPermit))
			}
		}
		
		tableView.reloadData()
	}
	
	// MARK: - Setup
	
	fileprivate func setupTableView() {

		// FIXME: Investigate if this is still required
//		tableView.rx.setDelegate(self)
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
				let cell = tableView.dequeueReusableCell(withIdentifier: "selectADifferenrPermit", for: indexPath)
				cell.textLabel?.text = indexPath.row == 0 ? "Select permit" : "Select a different permit"
				return cell
			}
		}
	}
	
	fileprivate func setupBindings() {
		
		Driver.combineLatest(status.asDriver(), existingPermits.asDriver(), draftPermits.asDriver(), resultSelector: unowned(self, AirMapRequiredPermitsViewController.sectionModels))
			.drive(tableView.rx.items(dataSource: dataSource))
			.disposed(by: disposeBag)
		
		Driver.combineLatest(selectedPermits.asDriver(), status.asDriver()) { ($0, $1) }
			.do(onNext: { [weak self] selected, status in
				self?.permitComplianceStatus.text = "You have selected \(selected.count) of \(status!.organizations.count) required permits"
			})
			.map { $0.count == $1?.organizations.count }
			.drive(nextButton.rx.isEnabled)
			.disposed(by: disposeBag)
		
		activityIndicator.asObservable()
			.throttle(0.25, scheduler: MainScheduler.instance)
			.distinctUntilChanged()
			.bindTo(rx_loading)
			.disposed(by: disposeBag)
	}
	
	fileprivate func loadData() {
		
		AirMap
			.rx.listPilotPermits()
			.trackActivity(activityIndicator)
			.map(unowned(self, AirMapRequiredPermitsViewController.filterOutInvalidPermits))
			.bindTo(existingPermits)
			.disposed(by: disposeBag)
	}
	
	fileprivate func filterOutInvalidPermits(_ permits: [AirMapPilotPermit]) -> [AirMapPilotPermit] {
		
		return permits
			// Only return available permits that are applicable and not expired
			.filter { status.value?.applicablePermits.map { $0.id }.contains($0.permitId) ?? false }
			.filter { $0.permitDetails.singleUse != true }
            .filter { ($0.expiresAt ?? Date.distantFuture).greaterThanDate(Date()) }
			.filter { $0.status != .rejected }
	}
	
	// MARK: - Instance Methods
	
	@IBAction func next() {

		trackEvent(.tap, label: "Next Button")

		if status.value!.supportsDigitalNotice {
			performSegue(withIdentifier: "pushFlightNotice", sender: self)
		} else {
			performSegue(withIdentifier: "pushReview", sender: self)
		}
	}
	
	fileprivate func sectionModels(_ status: AirMapStatus?, existingPermits: [AirMapPilotPermit], draftPermits: [AirMapPilotPermit]) -> [SectionData] {
		
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

	fileprivate func uncheckRowsInSection(_ section: Int) {
		for index in 0..<dataSource.sectionModels[section].items.count-1 {
			let indexPath = IndexPath(row: index, section: section)
			let cell = tableView.cellForRow(at: indexPath) as? AirMapPilotPermitCell
			cell?.imageView?.isHighlighted = false
		}
	}
	
}

extension AirMapRequiredPermitsViewController: UITableViewDelegate {

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let header = TableHeader(dataSource.sectionModels[section].model.name.uppercased())!
		header.textLabel.font = UIFont.systemFont(ofSize: 17)
		return header
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 45
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		
		let row = dataSource.sectionModels[indexPath.section].items[indexPath.row]
		let rowOrganization = row.organization
		
		guard let pilotPermit = row.pilotPermit else { return }

		if selectedPermits.value.filter ({$0.pilotPermit == pilotPermit && $0.organization == rowOrganization }).first != nil {
			cell.imageView?.isHighlighted = true
		} else {
			cell.imageView?.isHighlighted = false
		}
		
		// if draft, don't show wallet icon
		let isDraft = self.draftPermits.value.contains(pilotPermit)
		(cell as! AirMapPilotPermitCell).walletIcon.isHidden = isDraft
		(cell as! AirMapPilotPermitCell).walletIconSpacing.constant = isDraft ? -30 : 5
		(cell as! AirMapPilotPermitCell).setNeedsLayout()
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
				
		tableView.deselectRow(at: indexPath, animated: false)
		
		if let model = try? dataSource.sectionModels[indexPath.section].items[indexPath.row],
			let row = model as? RowData,
			let pilotPermit = row.pilotPermit {
			
			let cell = tableView.cellForRow(at: indexPath)
			
			if let alreadySelectedPermit = selectedPermits.value.filter({$0.permit.id == pilotPermit.permitId && $0.organization == row.organization}).first {
				selectedPermits.value = selectedPermits.value.filter { $0.permit !== alreadySelectedPermit.permit }
				cell?.imageView?.isHighlighted = false
			} else {
				uncheckRowsInSection(indexPath.section)
				if let previousSelectedOrgPermit = selectedPermits.value.filter({$0.organization.id == row.organization.id}).first {
					selectedPermits.value = selectedPermits.value.filter { $0 != previousSelectedOrgPermit }
				}
				
				selectedPermits.value.append((organization: row.organization, permit: row.availablePermit!, pilotPermit: pilotPermit))
				cell?.imageView?.isHighlighted = true
				trackEvent(.tap, label: "Selected Permit")
			}
		} else {
			trackEvent(.tap, label: "Selecte a Different Permit")
		}
	}
	
}
