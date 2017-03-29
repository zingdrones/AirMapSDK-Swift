//
//  AirMapLoginWithCodeViewController.swift
//  Pods
//
//  Created by Rocky Demoff on 3/3/17.
//
//

import Foundation

import RxSwift
import RxCocoa

open class AirMapLoginWithCodeViewController: UITableViewController, AnalyticsTrackable {
    
    var screenName = "SMS Login - Verify Code"
    var phoneNumber:String!
    
    @IBOutlet var submitButton: UIButton!
    @IBOutlet weak var smsCode: UITextField!
    @IBOutlet weak var smsTextField: UITextField!
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let activityIndicator = ActivityIndicator()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
        smsCode.becomeFirstResponder()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        trackView()
    }
    
    override open var canBecomeFirstResponder : Bool {
        
        return true
    }
    
    override open var inputAccessoryView: UIView? {
        
        return submitButton
    }
    
    fileprivate func setupBindings() {
        
        smsTextField.rx.text.asObservable()
            .map { $0?.characters.count == Config.AirMapApi.smsCodeLength }
            .bindTo(submitButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        activityIndicator.asObservable()
            .throttle(0.25, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bindTo(rx_loading)
            .disposed(by: disposeBag)
    }
    
    @IBAction func submitSMSCode() {
        
        trackEvent(.tap, label: "Submit Button")
        smsCode.resignFirstResponder()
		
//        AirMap.rx.performLoginWithCode(phoneNumber: phoneNumber, code: smsTextField.text!)
//            .trackActivity(activityIndicator)
//            .subscribe(onNext: { [unowned self] _ in
//                self.didAuthenticate()
//            }, onError: { [unowned self] error in
//                self.trackEvent(.save, label: "Error", value: NSNumber(value: (error as NSError).code))
//                self.didFailToAuthenticate(error as! Auth0Error)
//            }, onCompleted: {
//                self.trackEvent(.save, label: "Success")
//            })
//            .disposed(by: disposeBag)
        
    }
    
    fileprivate func didAuthenticate() {
        
        let nav = navigationController as! AirMapSMSLoginNavController
        nav.smsLoginDelegate?.smsLoginDidAuthenticate()

    }
    
    fileprivate func didFailToAuthenticate(_ error:Auth0Error) {
        
        let nav = navigationController as! AirMapSMSLoginNavController
        nav.smsLoginDelegate?.smsLogindidFailToAuthenticate(error: error)
        
    }
    
}
