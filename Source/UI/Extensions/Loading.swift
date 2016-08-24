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
	
		guard let window = UIApplication.sharedApplication().keyWindow else { return }
		
		let loader = LoadingView()
		loader.indicator.startAnimating()
		loader.frame = window.bounds
		
		UIView.transitionWithView(
			window,
			duration: 0.25,
			options: [.TransitionCrossDissolve, .AllowAnimatedContent],
			animations: { window.addSubview(loader) },
			completion: nil)
	}
	
	private func hideLoader() {
		
		guard let window = UIApplication.sharedApplication().keyWindow else { return }

		UIView.transitionWithView(
			window,
			duration: 0.25,
			options: [.TransitionCrossDissolve, .AllowAnimatedContent],
			animations: {
				window.subviews
					.map { $0 as? LoadingView }
					.flatMap { $0 }
					.forEach {
						$0.indicator.stopAnimating()
						$0.removeFromSuperview()
				}
			},
			completion: nil)
	}
	
}

class LoadingView: UIView {
	
	let indicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)

	override init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundColor = UIColor.airMapGray().colorWithAlphaComponent(0.75)
		addSubview(indicator)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()

		indicator.center = center
	}
	
}