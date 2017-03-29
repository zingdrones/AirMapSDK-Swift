//
//  AuthClient.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 8/9/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import Alamofire

internal class Auth0Client: HTTPClient {

	init() {
		super.init(basePath: Config.AirMapApi.Auth.ssoUrl)
	}

	func refreshAccessToken() -> Observable<AirMapToken> {
		AirMap.logger.debug("Refresh Access Token")

		guard let refreshToken = AirMap.authSession.getRefreshToken() else {
			return Observable.error(AirMapError.unauthorized)
		}

		let params = [
			"grant_type": Config.AirMapApi.Auth.grantType,
			"client_id": AirMap.configuration.auth0ClientId as Any,
			"api_type": "app",
			"refresh_token": refreshToken
		]

		return perform(method: .post, path:"/delegation", params: params, keyPath: nil)
			.do(onNext: { token in
				AirMap.authToken = token.authToken
			}, onError: { error in
				AirMap.logger.debug("ERROR: \(error)")
			})
    }
	
	func resendEmailVerification(_ resendLink: String?) {
		
		if let urlStr = resendLink?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! {
			Alamofire.request(urlStr, method: .get)
				.responseJSON { response in
			}
		}
	}
    
    func performPhoneNumberLogin(phoneNumber: String) -> Observable<Void> {
        
		let params = [
			"phone_number": phoneNumber,
			"client_id": AirMap.configuration.auth0ClientId as Any,
			"connection": "sms",
			"send": "code"
		]
		
        return perform(method: .post, path:"/passwordless/start", params: params, keyPath: nil)
    }
    
    func performLoginWithCode(phoneNumber:String, code:String) -> Observable<Auth0Credentials> {
		
		let deviceId: String
		
		#if os(OSX)
			deviceId = "macOS-" + UUID().uuidString
		#elseif os(Linux)
			deviceId = "linux-" + UUID().uuidString
		#else
			deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
		#endif
		
        let params = ["username": phoneNumber,
                      "password" : code,
                      "client_id": AirMap.configuration.auth0ClientId as Any,
                      "connection": "sms",
                      "grant_type": "password",
                      "device" : deviceId,
                      "scope" : "openid offline_access"]
        
        return perform(method: .post, path:"/oauth/ro", params: params, keyPath: nil)
            .do(onNext: { credentials in
                AirMap.authToken = credentials.idToken
                AirMap.authSession.saveRefreshToken(credentials.refreshToken)                
            }, onError: { error in
                AirMap.logger.debug("ERROR: \(error)")
            })
    }
    
    func logout() {
        AirMap.authToken = nil
    }
}
