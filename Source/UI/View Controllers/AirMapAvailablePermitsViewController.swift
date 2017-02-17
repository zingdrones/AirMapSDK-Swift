//
//  AirMapAvailablePermitsViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 11/1/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

/// Displays a list of existing, available, and unavailable permits for a specific organization
class AirMapAvailablePermitsViewController: UITableViewController, AnalyticsTrackable {
	
	var screenName = "Create Flight - Available Permits"
	
	@IBOutlet weak var header: UILabel!
	
	var status: AirMapStatus!
	var existingPermits: [AirMapPilotPermit]!
	var draftPermits: [AirMapPilotPermit]!	
	var organization: AirMapOrganization!
	
	private typealias RowData = (availablePermit: AirMapAvailablePermit, pilotPermit: AirMapPilotPermit?)
	private typealias SectionData = SectionModel<PermitStatus, RowData>

	private let dataSource = RxTableViewSectionedReloadDataSource<SectionData>()
	private let disposeBag = DisposeBag()
	
	private enum PermitStatus {
		case existing
		case available
		case unavailable
	}

	// MARK: - View Lifecycle

	override func viewDidLoad() {
        super.viewDidLoad()
		
		navigationItem.title = organization.name
		setupTable()
		setupBindings()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let identifier = segue.identifier else { return }
		
		switch identifier {

		case "pushNewPermit", "pushExistingPermit":
			if identifier == "pushNewPermit" {
				trackEvent(.tap, label: "Select Permit")
			} else {
				trackEvent(.tap, label: "Permit Details")
			}
			let cell = sender as! UITableViewCell
			let indexPath = tableView.indexPath(for: cell)!
			let permitVC = segue.destination as! AirMapAvailablePermitViewController
			
			let row = dataSource.sectionModels[indexPath.section].items[indexPath.row]
			permitVC.permit = Variable(row.availablePermit)
			permitVC.organization = organization

		case "unwindFromExistingPermit":
			let cell = sender as! UITableViewCell
			let indexPath = tableView.indexPath(for: cell)!
			let row = dataSource.sectionModels[indexPath.section].items[indexPath.row]
			let permitVC = segue.destination as! AirMapRequiredPermitsViewController
		
			var selectedPermits = permitVC.selectedPermits.value.filter { $0.permit.id != row.availablePermit.id }
			selectedPermits.append((organization, row.availablePermit, row.pilotPermit!))
			
			permitVC.selectedPermits.value = selectedPermits

		default:
			break
		}
	}
	
	// MARK: - Setup

	private func setupTable() {
	
		tableView.delegate = nil
		tableView.dataSource = nil
		
		tableView.estimatedRowHeight = 75
		tableView.rowHeight = UITableViewAutomaticDimension
		
		dataSource.configureCell = { dataSource, tableView, indexPath, row in
			let cell: AirMapPilotPermitCell
			switch dataSource.sectionModels[indexPath.section].model {
			case .existing:
				cell = tableView.cellWith(row, at: indexPath, withIdentifier: "availableExistingPermitCell")
			case .available:
				cell = tableView.cellWith(row, at: indexPath, withIdentifier: "availablePermitCell")
			case .unavailable:
				cell = tableView.cellWith(row, at: indexPath, withIdentifier: "unavailablePermitCell")
				cell.alpha = 0.333
			}
			return cell
		}
		
		dataSource.titleForHeaderInSection = { dataSource, section in
			switch dataSource.sectionModels[section].model {
			case .existing:
				return "Existing Permits"
			case .available:
				return "Available Permits"
			case .unavailable:
				return "Unavailable Permits"
			}
		}
	}
	
	private func setupBindings() {
		
		Driver.of(sectionModel(status, existingPermits: existingPermits, draftPermits: draftPermits))
			.drive(tableView.rx.items(dataSource: dataSource))
			.disposed(by: disposeBag)
	}
	
	// MARK: - Helper Functions
	
	private func sectionModel(_ status: AirMapStatus, existingPermits: [AirMapPilotPermit], draftPermits: [AirMapPilotPermit]) -> [SectionData] {
		
		let data = status.availablePermitsFor(organization)
			.map(rowData(existingPermits + draftPermits))
			.sorted(by: availablePermitNameAscending)
        
        let existing = try! data.filter(isApplicable).filter(isIssued)
        let available = data.filter(isApplicable).filter(isNotIssued)
        let unavailable = data.filter(isUnapplicable)
		
        // update the header copy
        header.text = headerCopy(available.count, existingPermitCount: existing.count)
        
		let sections: [SectionData] = [
			SectionData(model: .existing, items: existing),
			SectionData(model: .available, items: available),
			SectionData(model: .unavailable, items: unavailable)
		]
		
		return sections.filter { $0.items.count > 0 }
	}
        
    private func headerCopy(_ availablePermitCount: Int, existingPermitCount: Int)->String {
    
        var headerCopy = "The following exisiting & available permits meets the requirements for operation in the flight area."
        
        if existingPermitCount > 0 && availablePermitCount == 0 {
            let plural1 = existingPermitCount == 1 ? "" : "s"
            let plural2 = existingPermitCount == 1 ? "s" : ""
            headerCopy = "The following exisiting permit\(plural1) meet\(plural2) the requirements for operation in the flight area."
        }
        
        if existingPermitCount == 0 && availablePermitCount > 0 {
            let plural1 = availablePermitCount == 1 ? "" : "s"
            let plural2 = availablePermitCount == 1 ? "s" : ""
            headerCopy = "The following available permit\(plural1) meet\(plural2) the requirements for operation in the flight area."
        }
        
        if status.applicablePermits.count == 0 {
            headerCopy = "Only a single permit can be used to fly in this operating area. Your flight path intersects with multiple areas requiring different permits."
        }
        
       return headerCopy
    }
	
	private func rowData(_ pilotPermits: [AirMapPilotPermit]) -> (AirMapAvailablePermit) -> RowData {
		return { availablePermit in
			let pilotPermit = pilotPermits.filter { $0.permitId == availablePermit.id }.first
			return RowData(availablePermit, pilotPermit)
		}
	}
	
	private func availablePermitNameAscending(_ lhs: RowData, rhs: RowData) -> Bool {
		return lhs.availablePermit.name < rhs.availablePermit.name
	}
	
	private func isIssued(_ row: RowData) -> Bool {
		return row.pilotPermit != nil
	}
	
	private func isNotIssued(_ row: RowData) -> Bool {
		return !isIssued(row)
	}
	
	private func isApplicable(_ row: RowData) -> Bool {
		return status.applicablePermitsFor(organization)
			.filter { $0.id == row.availablePermit.id }
			.count > 0
	}
	
	private func isUnapplicable(_ row: RowData) -> Bool {
		return !isApplicable(row)
	}
	
}
