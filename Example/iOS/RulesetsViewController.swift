//
//  RulesetsViewController.swift
//  AirMapSDK-Example-iOS
//
//  Created by Adolfo Martinelli on 9/7/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import UIKit
import AirMap

protocol RulesetsViewControllerDelegate: class {
	func rulesetsViewControllerDidSelect(_ rulesets: [AirMapRuleset])
}

class RulesetsViewController: UITableViewController {
	
	var availableJurisdictions: [AirMapJurisdiction]!
	var preferredRulesets = [AirMapRuleset]()
	
	weak var delegate: RulesetsViewControllerDelegate?
	
	private var sections = [Section]()
	
	private struct Section {
		let jurisdiction: AirMapJurisdiction
		let type: AirMapRuleset.SelectionType
		let rulesets: [AirMapRuleset]
	}
	
	// MARK: - View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Build the tableview's section models from the available jurisdictions
		sections = sectionModels(from: availableJurisdictions)
	}
	
	// MARK: - Actions
	
	@IBAction func dismiss() {

		// Notify the delegate of the newly updated preferred rulesets
		delegate?.rulesetsViewControllerDidSelect(preferredRulesets)
		
		dismiss(animated: true)
	}
	
	// MARK: - Helper methods
	
	private func sectionModels(from jurisdictions: [AirMapJurisdiction]) -> [Section] {
		
		var sections = [Section]()
		
		// For each jurisdiction, create a section for pickOne, optional, and required rulesets
		// sorted by the jurisdiction region (federal -> state -> local, etc)
		for j in jurisdictions.sorted() {
			
			let pickOneSection = Section(jurisdiction: j, type: .pickOne, rulesets: j.pickOneRulesets)
			sections.append(pickOneSection)
			
			let optionalSection = Section(jurisdiction: j, type: .optional, rulesets: j.optionalRulesets)
			sections.append(optionalSection)
			
			let requiredSection = Section(jurisdiction: j, type: .required, rulesets: j.requiredRulesets)
			sections.append(requiredSection)
		}
		
		// Only return sections that have rulesets
		return sections.filter { $0.rulesets.count > 0 }
	}
	
	// MARK: - UITableViewDataSource
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sections[section].rulesets.count
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let sectionModel = sections[section]
		return "\(sectionModel.jurisdiction.name): \(sectionModel.type.name)"
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let section = sections[indexPath.section]
		let ruleset = section.rulesets[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "rulesetCell", for: indexPath)
		
		cell.selectionStyle = section.type == .required ? .none : .default
		cell.textLabel?.text = ruleset.name
		
		return cell
	}
	
	// MARK: - UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let section = sections[indexPath.section]
		let ruleset = section.rulesets[indexPath.row]
		
		if section.type == .required || preferredRulesets.contains(ruleset) {
			cell.accessoryType = .checkmark
		} else {
			cell.accessoryType = .none
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let section = sections[indexPath.section]
		let ruleset = section.rulesets[indexPath.row]
		
		switch section.type {
			
		// if an optional ruleset was selected, toggle it on or off
		case .optional:
			if preferredRulesets.contains(ruleset) {
				preferredRulesets.removeObject(ruleset)
			} else {
				preferredRulesets.append(ruleset)
			}
			tableView.reloadRows(at: [indexPath], with: .fade)
			
		// if an pickOne ruleset was selected ensure it is the only pickOne enabled from the jurisdiction
		case .pickOne:
			preferredRulesets.removeObjectsInArray(section.rulesets)
			preferredRulesets.append(ruleset)
			tableView.reloadSections([indexPath.section], animationStyle: .fade)
			
		// if an required ruleset was break since it must remain selected
		case .required:
			break
		}
	}
	
}
