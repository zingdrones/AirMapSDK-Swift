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
			title = advisory.name
			requiredPermits.value = advisory.requirements?.permitsAvailable ?? []
		}
	}

	let requiredPermits = Variable([AirMapAvailablePermit]())
	let draftPermits = Variable([AirMapPilotPermit]())
	let pilotPermits = Variable([AirMapPilotPermit]())
		
	private typealias RowType = (availablePermit: AirMapAvailablePermit, pilotPermit: AirMapPilotPermit?)
	private typealias SectionType = SectionModel<PermitStatus, RowType>

	private let dataSource = RxTableViewSectionedReloadDataSource<SectionType>()
	private let permits = Variable([RowType]())
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
	
	// MARK: - Setup

	private func setupTable() {
	
		tableView.delegate = nil
		tableView.dataSource = nil
		
		dataSource.configureCell = { dataSource, tableView, indexPath, row in
			switch dataSource.sectionAtIndex(indexPath.section).model {
			case .Existing:
				return tableView.cellWith(row, at: indexPath, withIdentifier: "availableExistingPermitCell") as AirMapPilotPermitCell
			case .Available, .Unavailable:
				return tableView.cellWith(row, at: indexPath, withIdentifier: "availablePermitCell") as AirMapPilotPermitCell
			}
		}
		
		dataSource.titleForHeaderInSection = { dataSource, section in
			switch dataSource.sectionAtIndex(section).model {
			case .Existing:
				return "Existing Permits"
			case .Available:
				return "Other Available Permits"
			case .Unavailable:
				return "Other Non-Available Permits"
			}
		}
	}
	
	private func setupBindings() {
		
		pilotPermits.asDriver()

		permits
			.asDriver()
			.map(sectionModel)
			.drive(tableView.rx_itemsWithDataSource(dataSource))
			.addDisposableTo(disposeBag)
	}
	
	// MARK: - Helper Functions
	
	private func sectionModel(permits: [RowType]) -> [SectionType] {
		
		return [
			SectionType(model: .Existing, items: permits.filter(isAvailable).filter(isIssued)),
			SectionType(model: .Available, items: permits.filter(isAvailable).filter(isNotIssued)),
			SectionType(model: .Unavailable, items: permits.filter(isUnavailable))
		]
	}
	
	private func isIssued(permit: RowType) -> Bool {
		return permit.pilotPermit != nil
	}
	
	private func isNotIssued(permit: RowType) -> Bool {
		return !isIssued(permit)
	}
	
	private func isAvailable(permit: RowType) -> Bool {
		// TODO:
		return true
	}
	
	private func isUnavailable(permits: RowType) -> Bool {
		// TODO:
		return false
	}
	
}
