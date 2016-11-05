//
//  AirMapFAQViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/18/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit

class AirMapFAQViewController: UIViewController {

	@IBOutlet var webView: UIWebView!
	
	enum Section: String {
		case LetOthersKnow = "let-others-know"
	}
	
	var section: Section? = nil
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let url = "https://cdn.airmap.io/static/webviews/faq.html#\(section?.rawValue ?? "")"
		let request = NSURLRequest(URL: NSURL(string: url)!)
		webView.loadRequest(request)
		webView.delegate = self
	}
	
	@IBAction func dismiss() {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
}

extension AirMapFAQViewController: UIWebViewDelegate {
	
	func webViewDidFinishLoad(webView: UIWebView) {
		webView.stringByEvaluatingJavaScriptFromString(
			"var h3Tags = document.getElementsByTagName('h3');" +
			"for (var i = h3Tags.length; i--;) {" +
			"  var h3 = h3Tags[i];" +
			"  h3.parentNode.removeChild(h3);" +
			"}"
		)
	}
}
