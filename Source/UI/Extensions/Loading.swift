//
//  Loading.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/9/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa

protocol Loading {}

extension UIViewController: Loading { }

extension Loading where Self: UIViewController {
	
	var rx_loading: AnyObserver<Bool> {
		return
			UIBindingObserver(UIElement: self) { vc, loading in
				loading ? vc.showLoader() : vc.hideLoader()
				}.asObserver()
	}
	
	private func showLoader() {
		
		view.inputAccessoryView?.userInteractionEnabled = false
		view.inputView?.userInteractionEnabled = false
			
		LoadingWindow.sharedInstance.makeKeyAndVisible()

		UIView.animateWithDuration(0.25, delay: 0, options: .BeginFromCurrentState, animations: {
			LoadingWindow.sharedInstance.alpha = 1
			}, completion: nil)
	}
	
	private func hideLoader() {
		
		let animations = {
			LoadingWindow.sharedInstance.alpha = 0
		}
		
		let completion = { (completed: Bool) in
			LoadingWindow.sharedInstance.hidden = true
			UIApplication.sharedApplication().windows.first?.makeKeyAndVisible()
			self.view.inputAccessoryView?.userInteractionEnabled = true
			self.view.inputView?.userInteractionEnabled = true
		}
		
		UIView.animateWithDuration(0.25, delay: 0, options: .BeginFromCurrentState, animations: animations, completion: completion)
	}
	
}

class LoadingWindow: UIWindow {
	
	private class LoadingRootViewController: UIViewController {
		private override func preferredStatusBarStyle() -> UIStatusBarStyle {
			return .LightContent
		}
	}

	static let sharedInstance: LoadingWindow = {

		let window = LoadingWindow(frame: UIScreen.mainScreen().bounds)
		window.rootViewController = LoadingRootViewController()
		window.backgroundColor = UIColor.airMapGray().colorWithAlphaComponent(0.75)
		window.windowLevel = UIWindowLevelAlert + 1
//		window.makeKeyAndVisible()
//		window.alpha = 0.0
		window.addSubview(window.indicator)
		window.indicator.center = window.center
		window.indicator.startAnimating()

		return window
	}()
	
	let indicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
	
}
