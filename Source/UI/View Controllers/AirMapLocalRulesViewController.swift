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

open class AirMapLocalRulesViewController: UITableViewController {

	open var localityRules: (name: String?, rules: [AirMapLocalRule])!

	fileprivate let disposeBag = DisposeBag()
	
    open override func viewDidLoad() {
        super.viewDidLoad()
		
		assert(localityRules != nil)
		navigationItem.title = localityRules.name ?? "Locality Rules"
		setupBindings()
	}

	open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "pushRuleDetails" {
			let cell = (sender as! UITableViewCell)
			let index = tableView.indexPath(for: cell)!
			let ruleVC = segue.destination as! AirMapLocalRuleViewController
			ruleVC.rule = try! tableView.rx.model(at: index)
		}
	}

	open override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
		
		if identifier == "pushRuleDetails" {
			if #available(iOS 9.0, *) {
				let cell = sender as! UITableViewCell
				let indexPath = tableView.indexPath(for: cell)!
				let rule = localityRules.rules[indexPath.row]
				if let url = rule.url {
					let safari = SFSafariViewController(url: url as URL)
					navigationController?.pushViewController(safari, animated: true)
					safari.navigationItem.title = rule.jurisdictionName
					return false
				} else {
					return super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
				}
			}
		}
		return super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
	}
	
	fileprivate func setupBindings() {
		
		tableView.dataSource = nil
		tableView.delegate = nil
		
		Driver.of(localityRules.rules)
			.drive(tableView.rx.items(cellIdentifier: "RuleCell", cellType: AirMapRuleCell.self.self)) {
				(index, rule, cell) in
				cell.jurisdictionName.text = rule.jurisdictionName
				cell.ruleText.text = rule.summary ?? rule.text
			}
			.addDisposableTo(disposeBag)
	}
	
}
