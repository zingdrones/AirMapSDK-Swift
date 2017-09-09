//
//  AdvisoriesViewController.swift
//  AirMapSDK-Example-iOS
//
//  Created by Adolfo Martinelli on 9/7/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import UIKit
import AirMap

class AdvisoriesViewController: UITableViewController {
	
	var rulesets: [AirMapRuleset]!
	var area: AirMapPolygon!
	
	private var sectionModels = [SectionModel]()
	
	private struct SectionModel {
		let type: AirMapAirspaceType
		let advisories: [AirMapAdvisory]
	}
	
	// MARK: - View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		getStatus(for: area)
	}
	
	// MARK: - Instance Methods
	
	private func getStatus(for area: AirMapPolygon) {
		
		tableView.refreshControl?.isEnabled = true
	
		let rulesetIds = rulesets.map({ $0.id })
		
		AirMap.getAirspaceStatus(within: area, rulesetIds: rulesetIds) { (result: Result<AirMapAirspaceStatus>) in
			
			switch result {
			
			case .error(let error):
				let alert = UIAlertController(title: "Error Getting Advisories", message: error.localizedDescription, preferredStyle: .alert)
				self.present(alert, animated: true, completion: nil)
			
			case .value(let status):
				self.sectionModels = self.sectionModels(for: status)
				self.tableView.reloadData()
			}
		}
	}
	
	private func sectionModels(for status: AirMapAirspaceStatus) -> [SectionModel] {
		
		return status.advisories
			// Sort by advisory color and name
			.sorted(by: { $0.0.color < $0.1.color && $0.0.name < $0.1.name })
			// Group by airspace type
			.grouped(by: { $0.type })
			// Map into a SectionModel
			.map(SectionModel.init)
			// Sorty by airspace type
			.sorted(by: { $0.0.type.title < $0.1.type.title })
	}
	
	//	MARK: - UITableViewDataSource
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return sectionModels.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sectionModels[section].advisories.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let sectionModel = sectionModels[indexPath.section]
		let advisory = sectionModel.advisories[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "advisoryCell", for: indexPath) as! AdvisoryCell
		cell.name?.text = advisory.name
		cell.color.backgroundColor = advisory.color.colorRepresentation
		return cell
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sectionModels[section].type.title
	}
	
}

class AdvisoryCell: UITableViewCell {
	
	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var color: UIView!
}
