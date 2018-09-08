//
//  AirMap+Auth.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/22/16.
//  Copyright 2018 AirMap, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

// MARK: - Auth Delegate

/// Protocol for handling AirMap authentication state changes
public protocol AirMapAuthSessionDelegate: class {
	func airmapSessionShouldAuthenticate()
	func airMapAuthSessionDidAuthenticate(_ pilot: AirMapPilot)
	func airMapAuthSessionAuthenticationDidFail(_ error: Error)
}

extension AirMap {
	
	// MARK: - Auth

	/// A JWT auth token that identifies the logged in user accessing the service. Required for all authenticated endpoints.
	public static var authToken: String? {
		didSet { authSession.authToken = authToken }
	}

	/// Setting the auth session delegate automatically calls the delegate whenever a pilot authenticated, fails to
	/// authenticate or needs to re-authenticate after a token expiration
	public static var authSessionDelegate: AirMapAuthSessionDelegate? {
		didSet { authSession.delegate = authSessionDelegate }
	}

	/// Refresh the auth token. Also notifies the `AirMapAuthSessionDelegate` upon completion
	///
	/// - Parameter completion: A completion handler to call with the Result
	public static func refreshAuthToken(_ completion: @escaping (Result<AirMapToken>) -> Void) {
		rx.refreshAuthToken().thenSubscribe(completion)
	}
    
    /// Authenticates an Anonymous User associated with the Developer API Key and returns an AuthToken.
    ///
    /// - Parameters:
    ///   - userId: a third-party, non-AirMap user id
    ///   - completion: A completion handler to call with the Result
    public static func performAnonymousLogin(userId: String, completion: @escaping (Result<AirMapToken>) -> Void) {
        rx.performAnonymousLogin(userId: userId).thenSubscribe(completion)
    }
	
	/// Initiates passwordless authentication by sending the provided phone number a verification code via SMS
	///
	/// - Parameters:
	///   - phoneNumber: The phone number to send the verification code to
	///   - completion: A completion handler to call with the Result
	public static func startPasswordlessLogin(with phoneNumber: String, completion: @escaping (Result<Void>) -> Void) {
        auth0Client.startPasswordlessLogin(with: phoneNumber).thenSubscribe(completion)
    }
    
	/// Completes passwordless login by verifying the phone number and verification code
	///
	/// - Parameters:
	///   - phoneNumber: The phone number to use for authentication
	///   - code: The SMS verification code that was received
	///   - completion: A completion handler to call with the Result
	public static func verifyPasswordlessLogin(with phoneNumber: String, code: String, completion: @escaping (Result<Auth0Credentials>) -> Void) {
        auth0Client.verifyPasswordlessLogin(with: phoneNumber, code: code).thenSubscribe(completion)
    }
    
    /// Log out the currently authenticated pilot
    public static func logout() {
        authToken = nil
	}
}
