//
//  AirMapReviewPermitsViewController.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 8/08/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class AirMapAuthViewController: UIViewController, UIWebViewDelegate {

	@IBOutlet weak var webView: UIWebView!

	public var authSessionDelegate: AirMapAuthSessionDelegate?
	var disposeBag = DisposeBag()

	//MARK: - View LifeCycle

	override public func viewDidLoad() {
		super.viewDidLoad()
		loadRequest()
	}

	//MARK: - Instance Methods

	@IBAction func dismiss(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
	}

	private func loadRequest() {
		webView.loadRequest(NSURLRequest(URL: NSURL(string: Config.AirMapApi.Auth.loginUrl)!))
	}

	/**
	Attempts to authenticate the

	- parameter urlString: The urlString to parse

	*/

	private func authenticateWithUrl(url: String) {

		AirMap.authToken = parseToken(url)

		AirMap.rx_getAuthenticatedPilot()
			.doOnError {[unowned self] error in
				self.loadRequest() // reload
				self.authSessionDelegate?.airMapAuthSessionAuthenticationDidFail(error as! NSError)
			}
			.subscribeNext {[unowned self]  pilot in
				self.authSessionDelegate?.airMapAuthSessionDidAuthenticate(pilot)
			}
			.addDisposableTo(disposeBag)
	}

	/**
	Parses the `id_token` from the query parameters of the url string

	- parameter urlString: The urlString to parse

	*/
	private func parseToken(urlString: String) -> String? {

		let urlComponents = NSURLComponents(string: urlString)
		let queryItems = urlComponents?.queryItems
		return queryItems?.filter({$0.name == "id_token"}).first?.value
	}

	//MARK: - UIWebViewDelegate Methods

	public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {

		if let host =  request.URL?.host, port = request.URL?.port?.integerValue {

			if host == Config.AirMapApi.Auth.callbackUrlHost && port == Config.AirMapApi.Auth.callbackUrlPort {

				let findString = "//\(host):\(port)\(Config.AirMapApi.Auth.callbackUrlPath)#"
				let replaceString = findString.stringByReplacingOccurrencesOfString("#", withString: "?")
				let url = request.URL!.absoluteString.stringByReplacingOccurrencesOfString(findString, withString: replaceString)
				authenticateWithUrl(url)
			}
		}

		return true
	}



}
