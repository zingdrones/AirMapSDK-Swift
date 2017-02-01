//
//  AirMapLocalRuleViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 1/11/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import UIKit
import SafariServices

public class AirMapLocalRuleViewController: UIViewController {
	
	var rule: AirMapLocalRule!
	@IBOutlet weak var ruleText: UITextView!

    public override func viewDidLoad() {
        super.viewDidLoad()
		
		let m = view.layoutMargins
		ruleText.textContainerInset = UIEdgeInsets(top: m.top+30, left: m.left+12, bottom: m.bottom+30, right: m.bottom+12)
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
