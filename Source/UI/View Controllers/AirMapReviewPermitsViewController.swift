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
	
	private typealias SectionData = SectionModel<AirMapOrganization, RowData>
	private typealias RowData = (permit: AirMapAvailablePermit?, pilotPermit: AirMapPilotPermit?, name: String, value: String?)
	private let dataSource = RxTableViewSectionedReloadDataSource<SectionData>()
	private let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		selectedPermits
			.asObservable()
			.map(unowned(self, AirMapReviewPermitsViewController.permitsToSectionModels))
			.bindTo(tableView.rx_itemsWithDataSource(dataSource))
			.addDisposableTo(disposeBag)

		dataSource.configureCell = { dataSource, tableView, indexPath, rowData in
			let cell: UITableViewCell
			if rowData.permit != nil {
				cell = tableView.dequeueReusableCellWithIdentifier("permitNameCell")!
			} else {
				cell = tableView.dequeueReusableCellWithIdentifier("permitDetailCell")!
			}
			cell.textLabel?.text = rowData.name
			cell.detailTextLabel?.text = rowData.value
			return cell
		}
		
		dataSource.titleForHeaderInSection = { dataSource, section in
			return dataSource.sectionAtIndex(section).model.name
		}
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		tableView.indexPathsForSelectedRows?.forEach { tableView.deselectRowAtIndexPath($0, animated: true) }
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
		if segue.identifier == "pushPermit" {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)!
            let section = dataSource.sectionAtIndex(indexPath.section)
            let rowData = section.items[indexPath.row]
            let permitVC = segue.destinationViewController as! AirMapAvailablePermitViewController
            permitVC.mode = .Review
            permitVC.permit = Variable(rowData.permit!)
            permitVC.pilotPermit = Variable(rowData.pilotPermit)
            permitVC.organization = section.model
		}
	}
	
	private func permitsToSectionModels(permits: [(organization: AirMapOrganization, permit: AirMapAvailablePermit, pilotPermit: AirMapPilotPermit)]) -> [SectionData] {

		return permits.map { permit in
			
			let permitRow: RowData = (permit: permit.permit, pilotPermit: permit.pilotPermit, name: permit.permit.name, value: nil)
			
			let customPropertyRows = permit.pilotPermit.customProperties.map { property -> RowData in
				(nil, nil, property.label, property.value)
			}
			return SectionData(model: permit.organization, items: [permitRow] + customPropertyRows)
		}
	}

}
