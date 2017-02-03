//
//  AirMap+Auth.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/22/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

public protocol AirMapAuthSessionDelegate: class {
	func airmapSessionShouldAuthenticate()
	func airMapAuthSessionDidAuthenticate(_ pilot: AirMapPilot)
	func airMapAuthSessionAuthenticationDidFail(_ error: Error)
}

private typealias AirMap_Auth = AirMap
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
		authClient.refreshAccessToken().subscribe(completion)
	}
    
    /// Log out the currently authenticated pilot
    public static func logout() {
        authClient.logout()
    }
	
	/// Re-send a verification email to the pilot's email address
	public static func resendEmailVerificationLink(_ resendLink: String?) {
		authClient.resendEmailVerification(resendLink)
	}

}
