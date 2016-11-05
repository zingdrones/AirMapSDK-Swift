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

/// Displays a list of exisiting, available, and unavailable permits for a specific organization
class AirMapAvailablePermitsViewController: UITableViewController {
	
	var advisory: AirMapStatusAdvisory! {
		didSet {
			navigationItem.title = advisory.name
			requiredPermits.value = advisory.requirements?.permitsAvailable ?? []
		}
	}

	var draftPermits: Variable<[AirMapPilotPermit]>!
	var pilotPermits: Variable<[AirMapPilotPermit]>!
	private let requiredPermits = Variable([AirMapAvailablePermit]())
	
	private typealias RowType = (requiredPermit: AirMapAvailablePermit, pilotPermit: AirMapPilotPermit?)
	private typealias SectionType = SectionModel<PermitStatus, RowType>

	private let dataSource = RxTableViewSectionedReloadDataSource<SectionType>()
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
			permitVC.permit = Variable(dataSource.itemAtIndexPath(indexPath).requiredPermit)
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
		
		Driver.combineLatest(requiredPermits.asDriver(), pilotPermits.asDriver(), draftPermits.asDriver(), resultSelector: permitData)
			.map(sectionModel)
			.drive(tableView.rx_itemsWithDataSource(dataSource))
			.addDisposableTo(disposeBag)
	}
	
	// MARK: - Helper Functions
	
	private func permitData(requiredPermits: [AirMapAvailablePermit], pilotPermits: [AirMapPilotPermit], draftPermits: [AirMapPilotPermit]) -> [RowType] {
		
		return requiredPermits
			.map { requiredPermit in
				let pilotPermit = (pilotPermits + draftPermits).filter { $0.permitId == requiredPermit.id }.first
				return RowType(requiredPermit: requiredPermit, pilotPermit: pilotPermit)
			}
			.sort { $0.0.requiredPermit.name < $0.1.requiredPermit.name }
	}
	
	private func sectionModel(permits: [RowType]) -> [SectionType] {
		
		return [
			SectionType(model: .Existing, items: permits.filter(isApplicable).filter(isIssued)),
			SectionType(model: .Available, items: permits.filter(isApplicable).filter(isNotIssued)),
			SectionType(model: .Unavailable, items: permits.filter(isUnapplicable))
		]
	}
	
	private func isIssued(row: RowType) -> Bool {
		return row.pilotPermit != nil
	}
	
	private func isNotIssued(row: RowType) -> Bool {
		return !isIssued(row)
	}
	
	private func isApplicable(row: RowType) -> Bool {
		return row.requiredPermit.isApplicable
	}
	
	private func isUnapplicable(row: RowType) -> Bool {
		return !row.requiredPermit.isApplicable
	}
	
}
