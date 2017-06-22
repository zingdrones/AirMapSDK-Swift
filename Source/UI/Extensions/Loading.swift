//
//  Loading.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/9/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa

public protocol Loading {}

extension UIViewController: Loading { }

extension Loading where Self: UIViewController {
	
	public var rx_loading: AnyObserver<Bool> {
		return
			UIBindingObserver(UIElement: self) { vc, loading in
				loading ? vc.showLoader() : vc.hideLoader()
				}.asObserver()
	}

	fileprivate func showLoader() {
		
		view.inputAccessoryView?.isUserInteractionEnabled = false
		view.inputView?.isUserInteractionEnabled = false
			
		LoadingWindow.sharedInstance.makeKeyAndVisible()

		UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: {
			LoadingWindow.sharedInstance.alpha = 1
			}, completion: nil)
	}
	
	fileprivate func hideLoader() {
		
		let animations = {
			LoadingWindow.sharedInstance.alpha = 0
		}
		
		let completion = { (completed: Bool) in
			LoadingWindow.sharedInstance.isHidden = true
			UIApplication.shared.windows.first?.makeKeyAndVisible()
			self.view.inputAccessoryView?.isUserInteractionEnabled = true
			self.view.inputView?.isUserInteractionEnabled = true
		}
		
		UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: animations, completion: completion)
	}
	
}

class LoadingWindow: UIWindow {
	
	fileprivate class LoadingRootViewController: UIViewController {
		fileprivate override var preferredStatusBarStyle : UIStatusBarStyle {
			return .lightContent
		}
	}

	static let sharedInstance: LoadingWindow = {

		let window = LoadingWindow(frame: UIScreen.main.bounds)
		window.rootViewController = LoadingRootViewController()
		window.backgroundColor = UIColor.airMapDarkGray.withAlphaComponent(0.75)
		window.windowLevel = UIWindowLevelAlert + 1
		window.addSubview(window.indicator)
		window.indicator.center = window.center
		window.indicator.startAnimating()

		return window
	}()
	
	let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
	
}
