//
//  ExamplesViewController.swift
//  AirMapSDK-Example-iOS
//
//  Created by Adolfo Martinelli on 9/8/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import UIKit

class ExamplesViewController: UITableViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.estimatedRowHeight = 80
		tableView.rowHeight = UITableViewAutomaticDimension
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		if let loginExampleVC = segue.destination as? LoginExampleViewController {
			if segue.identifier == "anonymousLogin" {
				loginExampleVC.useCase = .anonymousUser
			}
			if segue.identifier == "airMapLogin" {
				loginExampleVC.useCase = .airMapUser
			}
		}
	}
	
}
