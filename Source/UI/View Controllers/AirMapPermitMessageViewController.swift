//
//  AirMapPermitMessageViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/21/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

class AirMapPermitMessageViewController: UIViewController {
	
	@IBOutlet weak var messageLabel: UILabel!
	
	var message: String?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		messageLabel.text = message
	}
	
}