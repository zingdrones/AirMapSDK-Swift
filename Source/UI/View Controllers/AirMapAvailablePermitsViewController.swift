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
		case Existing
		case Available
		case Unavailable
	}

	// MARK: - View Lifecycle

	override func viewDidLoad() {
        super.viewDidLoad()
		
		navigationItem.title = organization.name
		setupTable()
		setupBindings()
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		guard let identifier = segue.identifier else { return }
		switch identifier {
		case "pushNewPermit", "pushExistingPermit":
			if identifier == "pushNewPermit" {
				trackEvent(.tap, label: "Select Permit")
			} else {
				trackEvent(.tap, label: "Permit Details")
			}
			let cell = sender as! UITableViewCell
			let indexPath = tableView.indexPathForCell(cell)!
			let permitVC = segue.destinationViewController as! AirMapAvailablePermitViewController
			permitVC.permit = Variable(dataSource.itemAtIndexPath(indexPath).availablePermit)
			permitVC.organization = organization
		case "unwindFromExistingPermit":
			let cell = sender as! UITableViewCell
			let indexPath = tableView.indexPathForCell(cell)!
			let permit = dataSource.itemAtIndexPath(indexPath)
			let permitVC = segue.destinationViewController as! AirMapRequiredPermitsViewController
		
			var selectedPermits = permitVC.selectedPermits.value.filter { $0.permit.id != permit.availablePermit.id }
			selectedPermits.append((organization, permit.availablePermit, permit.pilotPermit!))
			
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
			switch dataSource.sectionAtIndex(indexPath.section).model {
			case .Existing:
				cell = tableView.cellWith(row, at: indexPath, withIdentifier: "availableExistingPermitCell")
			case .Available:
				cell = tableView.cellWith(row, at: indexPath, withIdentifier: "availablePermitCell")
			case .Unavailable:
				cell = tableView.cellWith(row, at: indexPath, withIdentifier: "unavailablePermitCell")
				cell.alpha = 0.333
			}
			return cell
		}
		
		dataSource.titleForHeaderInSection = { dataSource, section in
			switch dataSource.sectionAtIndex(section).model {
			case .Existing:
				return "Existing Permits"
			case .Available:
				return "Available Permits"
			case .Unavailable:
				return "Unavailable Permits"
			}
		}
	}
	
	private func setupBindings() {
		
		Driver.of(sectionModel(status, existingPermits: existingPermits, draftPermits: draftPermits))
			.drive(tableView.rx_itemsWithDataSource(dataSource))
			.addDisposableTo(disposeBag)
	}
	
	// MARK: - Helper Functions
	
	private func sectionModel(status: AirMapStatus, existingPermits: [AirMapPilotPermit], draftPermits: [AirMapPilotPermit]) -> [SectionData] {
		
		let data = status.availablePermitsFor(organization)
			.map(rowData(existingPermits + draftPermits))
			.sort(availablePermitNameAscending)
        
        let existing = data.filter(isApplicable).filter(isIssued)
        let available = data.filter(isApplicable).filter(isNotIssued)
        let unavailable = data.filter(isUnapplicable)
        
        // update the header copy
        header.text = headerCopy(available.count, existingPermitCount: existing.count)
        
		let sections = [
			SectionData(model: .Existing, items: existing),
			SectionData(model: .Available, items: available),
			SectionData(model: .Unavailable, items: unavailable)
		]
		
		return sections.filter { $0.items.count > 0 }
	}
    
    
    private func headerCopy(availablePermitCount:Int, existingPermitCount:Int)->String {
    
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
	
	private func rowData(pilotPermits: [AirMapPilotPermit]) -> AirMapAvailablePermit -> RowData {
		return { availablePermit in
			let pilotPermit = pilotPermits.filter { $0.permitId == availablePermit.id }.first
			return RowData(availablePermit, pilotPermit)
		}
	}
	
	private func availablePermitNameAscending(lhs: RowData, rhs: RowData) -> Bool {
		return lhs.availablePermit.name < rhs.availablePermit.name
	}
	
	private func isIssued(row: RowData) -> Bool {
		return row.pilotPermit != nil
	}
	
	private func isNotIssued(row: RowData) -> Bool {
		return !isIssued(row)
	}
	
	private func isApplicable(row: RowData) -> Bool {
		return status.applicablePermitsFor(organization)
			.filter { $0.id == row.availablePermit.id }
			.count > 0
	}
	
	private func isUnapplicable(row: RowData) -> Bool {
		return !isApplicable(row)
	}
	
}
