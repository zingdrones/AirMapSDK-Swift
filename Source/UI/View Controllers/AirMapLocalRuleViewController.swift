//
//  AirMapLocalRuleViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 1/11/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import UIKit
import SafariServices

open class AirMapLocalRuleViewController: UIViewController {
	
	var rule: AirMapLocalRule!
	@IBOutlet weak var ruleText: UITextView!

    open override func viewDidLoad() {
        super.viewDidLoad()
		
		let m = view.layoutMargins
		ruleText.textContainerInset = UIEdgeInsets(top: m.top+30, left: m.left+12, bottom: m.bottom+30, right: m.bottom+12)
		navigationItem.title = rule.jurisdictionName
		
		if let url = rule.url {
			ruleText.removeFromSuperview()
			
			let webView = UIWebView()
			view.addSubview(webView)
			webView.frame = view.bounds
			webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			let request = URLRequest(url: url as URL)
			webView.loadRequest(request)
			
		} else {
			ruleText.text = rule.text
		}
    }

}
