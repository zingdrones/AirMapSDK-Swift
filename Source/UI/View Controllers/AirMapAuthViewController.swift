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
import Lock

public typealias AirMapAuthHandler = (Result<AirMapPilot>) -> Void

public enum AirMapAuthError: Error {
	case emailVerificationNeeded(resendLink: String)
	case emailBlacklisted
	case error(description: String)
}

open class AirMapAuthViewController: A0LockViewController {
	
	init(authHandler: @escaping AirMapAuthHandler) {
		let lock = A0Lock.init(clientId: AirMap.configuration.auth0ClientId, domain: "sso.airmap.io", configurationDomain: "sso.airmap.io")
		super.init(lock: lock)
		setup(authHandler)
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	fileprivate func setup(_ authHandler: @escaping AirMapAuthHandler) {
		registerTheme()
		
		loginAfterSignUp = true
		closable = true
		
		onAuthenticationBlock = { profile, token in
			guard let authToken = token else {
				AirMap.logger.error("Unexpectedly failed to acquire token after login"); return
			}
			AirMap.authToken = authToken.idToken
			AirMap.authSession.saveRefreshToken(authToken.refreshToken)
			AirMap.rx.getAuthenticatedPilot().subscribe(authHandler)
		}
	}

	open func registerLogo(_ imageName: String, bundle: Bundle){
		A0Theme.sharedInstance().registerImage(withName: imageName, bundle: bundle, forKey: A0ThemeIconImageName)
	}
	
	fileprivate func registerTheme() {
		let theme = A0Theme()
		
		theme.registerImage(withName: "lock_login_image", bundle: Bundle(for: AirMap.self), forKey: A0ThemeIconImageName)

		theme.register(UIColor.airMapDarkGray, forKey: A0ThemePrimaryButtonNormalColor)
		theme.register(UIColor.airMapDarkGray, forKey: A0ThemePrimaryButtonHighlightedColor)
		A0Theme.sharedInstance().register(theme)
	}
}

import AFNetworking

extension AFJSONResponseSerializer {
	
	open override class func initialize() {
		
		guard self == NSClassFromString("A0JSONResponseSerializer") else {
			return
		}
		
		// FIXME: May need to wrap in dispatch_once equivalent
	
		let originalSelector = #selector(AFJSONResponseSerializer.responseObject(for: data: error:))
		let swizzledSelector = #selector(AFJSONResponseSerializer.airmap_responseObject(for: data: error:))
		
		let originalMethod = class_getInstanceMethod(self, originalSelector)
		let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
		
		let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
		
		if didAddMethod {
			class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
		} else {
			method_exchangeImplementations(originalMethod, swizzledMethod)
		}
	}
	
	// MARK: - Method Swizzling
	
	public func airmap_responseObject(for response: URLResponse?, data: Data?, error: NSErrorPointer) -> AnyObject? {
		
		guard (response as? HTTPURLResponse)?.statusCode == 401 else {
			return airmap_responseObject(for: response, data: data, error: error)
		}
		
		if let payload = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as? [String: Any],
			let payloadString = payload?["error_description"] as? String {
			if let payloadData = payloadString.data(using: String.Encoding.utf8) {
				if let errorDict = try? JSONSerialization.jsonObject(with: payloadData, options: JSONSerialization.ReadingOptions()) as? [String: Any] {
					
					if let resendLink = errorDict?["resend_link"] as? String{
						AirMap.resendEmailVerificationLink(resendLink)
					}
					
					if let type = errorDict?["type"] as? String {
						let message: String
						switch type {
						case "email_verification":
							message = "Your email address needs to be verified. Please check your inbox."
						case "domain_blacklist":
							message = "Your account has been blacklisted. Please contact security@airmap.com"
						default:
							message = "Unauthorized"
						}
						let dict = [
							"error": "unauthorized",
							"error_description": message
						]
						let data = try! JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions())
						return airmap_responseObject(for: response, data: data, error: error)
					}
				}
			}
		}
		
		return airmap_responseObject(for: response, data: data, error: error)
	}
	
}

extension UIAlertController {
	
	open override class func initialize() {
		
		guard self == NSClassFromString("UIAlertController") else {
			return
		}
		
		struct Static {
			static var token: Int = 0
		}
		
		let originalSelector = #selector(UIAlertController.viewWillAppear(_:))
		let swizzledSelector = #selector(UIAlertController.airmap_viewWillAppear(_:))
		
		let originalMethod = class_getInstanceMethod(self, originalSelector)
		let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
		
		let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
		
		if didAddMethod {
			class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
		} else {
			method_exchangeImplementations(originalMethod, swizzledMethod)
		}
	}
	
	public func airmap_viewWillAppear(_ animated: Bool) {
		// Updating Auth0 Alert Title
		if title == "There was an error logging in" || title == "There was an error signing up" {
			title = "Alert"
		}
	}
}
