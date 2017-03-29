//
//  AirMap+Auth.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/22/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

public protocol AirMapAuthSessionDelegate: class {
	func airmapSessionShouldAuthenticate()
	func airMapAuthSessionDidAuthenticate(_ pilot: AirMapPilot)
	func airMapAuthSessionAuthenticationDidFail(_ error: Error)
}

public typealias AirMap_Auth = AirMap
extension AirMap_Auth {

	/// Setting the auth session delegate automatically calls the delegate whenever a pilot authenticated, fails to
	/// authenticate or needs to re-authenticate after a token expiration
	public static var authSessionDelegate: AirMapAuthSessionDelegate? {
		didSet { authSession.delegate = authSessionDelegate }
	}

	/// Refresh the auth token. Also notifies the `AirMapAuthSessionDelegate` upon completion
	///
	///   - completion: A completion handler to call with the Result
	public static func refreshAuthToken(_ completion: @escaping (Result<AirMapToken>) -> Void) {
		auth0Client.refreshAccessToken().subscribe(completion)
	}
    
    /// Authenticates an Anonymous User associated with the Developer API Key and returns an AuthToken.
    ///   - completion: A completion handler to call with the Result
    public static func performAnonymousLogin(userId:String, completion: @escaping (Result<AirMapToken>) -> Void) {
        authClient.performAnonymousLogin(userId: userId).subscribe(completion)
    }
	
    ///  Starts passwordless authentication by sending an sms with an OTP code
    ///   - completion: A completion handler to call with the Result
	@available(*, unavailable)
    public static func performPhoneNumberLogin(phoneNumber:String, completion: @escaping (Result<Void>) -> Void) {
        auth0Client.performPhoneNumberLogin(phoneNumber: phoneNumber).subscribe(completion)
    }
    
    ///  Authenticates passwordless authentication with a Code and returns an AuthToken.
    ///   - completion: A completion handler to call with the Result
	@available(*, unavailable)
	public static func performLoginWithCode(phoneNumber:String, code:String, completion: @escaping (Result<Auth0Credentials>) -> Void) {
        auth0Client.performLoginWithCode(phoneNumber: phoneNumber, code: code).subscribe(completion)
    }
    
    /// Log out the currently authenticated pilot
    public static func logout() {
        auth0Client.logout()
    }
	
	/// Re-send a verification email to the pilot's email address
	public static func resendEmailVerificationLink(_ resendLink: String?) {
		auth0Client.resendEmailVerification(resendLink)
	}

}
