//
//  AirMapAuthSession.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/20/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import JWTDecode
import RxSwift
import RxSwiftExt

class AirMapAuthSession {

	var authToken: String? {
		didSet {
			if let authToken = authToken {
				decodeToken(authToken)
			} else {
				userId = ""
			}
		}
	}

	var tokenType: String = "Bearer"
	var enableCertificatePinning: Bool = false
	var apiKey: String?
	var userId: String = ""
	var expiresAt: NSDate!
	var delegate: AirMapAuthSessionDelegate?

	private let disposeBag = DisposeBag()

	init() {
		setupBindings()
	}

	private func setupBindings() {

		let expiredDateInterval = Observable<Int>
			.interval(60, scheduler: MainScheduler.instance)
			.mapToVoid()

		expiredDateInterval
			.subscribeNext(unowned(self, AirMapAuthSession.verifyAuthentication))
			.addDisposableTo(disposeBag)
	}

	/**
	Decodes a JWT token and sets the userId and expiresAt properties

	- parameter jwt: The JWT Token to decode

	*/
	private func decodeToken(jwt: String) {

		if jwt.isEmpty {
			self.authToken = nil
			self.userId = ""
		}

		guard let decoded = try? JWTDecode.decode(jwt) else {

			delegate?.airmapSessionShouldReauthenticate { (token) in
				AirMap.logger.debug("Attempting to reauthenticate with new token", token)
				self.authToken = token
			}

			return
		}

		expiresAt = decoded.expiresAt
		userId = decoded.subject ?? ""

		AirMap.logger.debug("Decoded Token User Id", userId)
	}

	/**

	If token is expired then ask the delegate for a new Auth Token

	*/
	private func verifyAuthentication() {

		guard let expiresAt = expiresAt else { return }

		if !hasValidCredentials() {

			if NSDate().greaterThanDate(expiresAt.dateBySubtractingTimeInterval(60*5)) {
				self.expiresAt = nil
			}

			delegate?.airmapSessionShouldReauthenticate { (token) in
				AirMap.logger.debug("airmapSessionShouldReauthenticate", token)
				self.authToken = token
			}
		}
	}

	/// Checks for an expired token and returns a Boolean
	private func tokenIsExpired() -> Bool {
		guard let expiresAt = expiresAt else { return true }
		return NSDate().greaterThanDate(expiresAt)
	}

	/// Validates the credentials and returns a Bool
	func hasValidCredentials() -> Bool {
		return authToken != nil && !authToken!.isEmpty && apiKey != nil && !apiKey!.isEmpty && !tokenIsExpired()
	}

	/// Validates the credentials and returns a Bool
	func hasValidApiKey() -> Bool {
		return apiKey != nil && !apiKey!.isEmpty
	}

}
