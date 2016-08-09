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
	
	let selectedPermits = Variable([(advisory: AirMapStatusAdvisory, permit: AirMapAvailablePermit, pilotPermit: AirMapPilotPermit)]())
	
	@IBOutlet var tableView: UITableView!
	
	private typealias RowData = (permit: AirMapAvailablePermit?, pilotPermit: AirMapPilotPermit?, name: String, value: String?)
	private let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<AirMapStatusAdvisory,RowData>>()
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
			let rowData = try! tableView.rx_modelAtIndexPath(indexPath) as RowData
			let permitVC = segue.destinationViewController as! AirMapAvailablePermitViewController
			permitVC.mode = .Review
			permitVC.permit = Variable(rowData.permit!)
			permitVC.advisory = section.model
		}
	}
	
	private func permitsToSectionModels(permits: [(advisory: AirMapStatusAdvisory, permit: AirMapAvailablePermit, pilotPermit: AirMapPilotPermit)]) -> [SectionModel<AirMapStatusAdvisory, RowData>] {

		return permits.map { permit in
			
			let permitRow: RowData = (permit: permit.permit, pilotPermit: permit.pilotPermit, name: permit.permit.name, value: nil)
			
			let customPropertyRows = permit.pilotPermit.customProperties.map { property -> RowData in
				(nil, nil, property.label, property.value)
			}
			return SectionModel(model: permit.advisory, items: [permitRow] + customPropertyRows)
		}
	}

}
