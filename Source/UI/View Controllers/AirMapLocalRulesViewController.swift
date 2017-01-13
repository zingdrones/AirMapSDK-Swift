//
//  AirMapLocalRulesViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 1/10/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SafariServices

class AirMapLocalRulesViewController: UITableViewController {

	var localityRules: (name: String?, rules: [AirMapLocalRule])!

	private let disposeBag = DisposeBag()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		assert(localityRules != nil)
		navigationItem.title = localityRules.name ?? "Locality Rules"
		setupBindings()
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
		if segue.identifier == "pushRuleDetails" {
			let cell = (sender as! UITableViewCell)
			let index = tableView.indexPathForCell(cell)!
			let ruleVC = segue.destinationViewController as! AirMapLocalRuleViewController
			ruleVC.rule = try! tableView.rx_modelAtIndexPath(index)
		}
	}

	override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
		
		if identifier == "pushRuleDetails" {
			if #available(iOS 9.0, *) {
				let cell = sender as! UITableViewCell
				let indexPath = tableView.indexPathForCell(cell)!
				let rule = localityRules.rules[indexPath.row]
				if let url = rule.url {
					let safari = SFSafariViewController(URL: url)
					navigationController?.pushViewController(safari, animated: true)
					safari.navigationItem.title = rule.jurisdictionName
					return false
				} else {
					return super.shouldPerformSegueWithIdentifier(identifier, sender: sender)
				}
			}
		}
		return super.shouldPerformSegueWithIdentifier(identifier, sender: sender)
	}
	
	private func setupBindings() {
		
		tableView.dataSource = nil
		tableView.delegate = nil
		
		Driver.of(localityRules.rules)
			.drive(tableView.rx_itemsWithCellIdentifier("RuleCell", cellType: AirMapRuleCell.self.self)) {
				(index, rule, cell) in
				cell.jurisdictionName.text = rule.jurisdictionName
				cell.ruleText.text = rule.summary ?? rule.text
			}
			.addDisposableTo(disposeBag)
	}
	
}
