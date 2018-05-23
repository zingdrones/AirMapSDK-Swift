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
			Binder(self, binding: { (vc, loading) in
				loading ? vc.showLoader() : vc.hideLoader()
			}).asObserver()
	}

	fileprivate func showLoader() {

		LoadingWindow.shared.makeKeyAndVisible()
		view.inputAccessoryView?.isUserInteractionEnabled = false
		view.inputView?.isUserInteractionEnabled = false

		let animations = {
			LoadingWindow.shared.alpha = 1
		}

		UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: animations, completion: nil)
	}

	fileprivate func hideLoader() {

		UIApplication.shared.windows.first?.makeKeyAndVisible()
		self.view.inputAccessoryView?.isUserInteractionEnabled = true
		self.view.inputView?.isUserInteractionEnabled = true

		let animations = {
			LoadingWindow.shared.alpha = 0
		}

		let completion = { (completed: Bool) in
			LoadingWindow.shared.isHidden = true
		}

		UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: animations, completion: completion)
	}

}

class LoadingWindow: UIWindow {
    
    fileprivate class LoadingRootViewController: UIViewController {
        
        private let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

        override var shouldAutorotate: Bool {
            return true
        }
        
        override var preferredStatusBarStyle : UIStatusBarStyle {
            return .lightContent
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            indicator.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(indicator)
            
            NSLayoutConstraint.activate([
                indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                ])
            
            indicator.startAnimating()
        }
    }

    static let shared: LoadingWindow = {

        let window = LoadingWindow(frame: UIScreen.main.bounds)
        window.rootViewController = LoadingRootViewController()
        window.backgroundColor = UIColor.airMapDarkGray.withAlphaComponent(0.75)
        window.windowLevel = UIWindowLevelAlert + 1
        
        return window
    }()
	
}
