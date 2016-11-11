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
class AirMapAvailablePermitsViewController: UITableViewController {
	
	var status: AirMapStatus!
	var existingPermits: [AirMapPilotPermit]!
	var draftPermits: [AirMapPilotPermit]!	
	var organization: AirMapOrganization! {
		didSet { navigationItem.title = organization.name }
	}
	
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
		
		setupTable()
		setupBindings()
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		guard let identifier = segue.identifier else { return }
		switch identifier {
		case "pushNewPermit", "pushExistingPermit":
			let cell = sender as! UITableViewCell
			let indexPath = tableView.indexPathForCell(cell)!
			let permitVC = segue.destinationViewController as! AirMapAvailablePermitViewController
			permitVC.permit = Variable(dataSource.itemAtIndexPath(indexPath).availablePermit)
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
		
		return [
			SectionData(model: .Existing, items: data.filter(isApplicable).filter(isIssued)),
			SectionData(model: .Available, items: data.filter(isApplicable).filter(isNotIssued)),
			SectionData(model: .Unavailable, items: data.filter(isUnapplicable))
		]
	}
	
	private func rowData(pilotPermits: [AirMapPilotPermit]) -> (AirMapAvailablePermit) -> RowData {
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
		return status.applicablePermits.contains(row.availablePermit)
	}
	
	private func isUnapplicable(row: RowData) -> Bool {
		return !isApplicable(row)
	}
	
}
