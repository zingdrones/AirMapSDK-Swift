//
//  AirMapLocalRuleViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 1/11/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import UIKit
import SafariServices

class AirMapLocalRuleViewController: UIViewController {
	
	var rule: AirMapLocalRule!
	@IBOutlet weak var ruleText: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		navigationItem.title = rule.jurisdictionName
		
		if let url = rule.url {
			ruleText.removeFromSuperview()
			
			let webView = UIWebView()
			view.addSubview(webView)
			webView.frame = view.bounds
			webView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
			let request = NSURLRequest(URL: url)
			webView.loadRequest(request)
			
		} else {
			ruleText.text = rule.text
		}
    }

}
