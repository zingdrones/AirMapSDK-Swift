//
//  AirMapReviewPermitsViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/25/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

class AirMapReviewPermitsViewController: UIViewController {
	
	let selectedPermits = Variable([(organization: AirMapOrganization, permit: AirMapAvailablePermit, pilotPermit: AirMapPilotPermit)]())
	
	@IBOutlet var tableView: UITableView!
	
	fileprivate typealias SectionData = SectionModel<AirMapOrganization, RowData>
	fileprivate typealias RowData = (permit: AirMapAvailablePermit?, pilotPermit: AirMapPilotPermit?, name: String, value: String?)
	fileprivate let dataSource = RxTableViewSectionedReloadDataSource<SectionData>()
	fileprivate let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		dataSource.configureCell = { dataSource, tableView, indexPath, rowData in
			let cell: UITableViewCell
			if rowData.permit != nil {
				cell = tableView.dequeueReusableCell(withIdentifier: "permitNameCell")!
			} else {
				cell = tableView.dequeueReusableCell(withIdentifier: "permitDetailCell")!
			}
			cell.textLabel?.text = rowData.name
			cell.detailTextLabel?.text = rowData.value
			return cell
		}
		
		dataSource.titleForHeaderInSection = { dataSource, index in
			return dataSource.sectionModels[index].model.name
		}

		selectedPermits
			.asObservable()
			.map(unowned(self, AirMapReviewPermitsViewController.permitsToSectionModels))
			.bind(to: tableView.rx.items(dataSource: dataSource))
			.disposed(by: disposeBag)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		tableView.indexPathsForSelectedRows?.forEach { tableView.deselectRow(at: $0, animated: true) }
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "pushPermit" {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)!
            let section = dataSource.sectionModels[indexPath.section]
            let rowData = section.items[indexPath.row]
            let permitVC = segue.destination as! AirMapAvailablePermitViewController
            permitVC.mode = .review
            permitVC.permit = Variable(rowData.permit!)
            permitVC.pilotPermit = Variable(rowData.pilotPermit)
            permitVC.organization = section.model
		}
	}
	
	fileprivate func permitsToSectionModels(_ permits: [(organization: AirMapOrganization, permit: AirMapAvailablePermit, pilotPermit: AirMapPilotPermit)]) -> [SectionData] {

		return permits.map { permit in
			
			let permitRow: RowData = (permit: permit.permit, pilotPermit: permit.pilotPermit, name: permit.permit.name, value: nil)
			
			let customPropertyRows = permit.pilotPermit.customProperties.map { property -> RowData in
				(nil, nil, property.label, property.value)
			}
			return SectionData(model: permit.organization, items: [permitRow] + customPropertyRows)
		}
	}

}
