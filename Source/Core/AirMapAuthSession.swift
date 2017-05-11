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
import SimpleKeychain

class AirMapAuthSession {

	var authToken: String? {
		didSet {
			if let authToken = authToken {
				decodeToken(authToken)
			} else {
				userId = ""
				AirMapAuthSession.saveRefreshToken(nil)
			}
		}
	}
	var refreshToken: String? {
		didSet {
			AirMapAuthSession.saveRefreshToken(refreshToken)
		}
	}

	internal var tokenType: String = "Bearer"
	internal var enableCertificatePinning: Bool = false
	internal var userId: String = ""
	internal var expiresAt: Date!
	internal weak var delegate: AirMapAuthSessionDelegate?

	private let disposeBag = DisposeBag()

	init() {
		setupBindings()
	}

	private func setupBindings() {

		let expiredDateInterval = Observable<Int>
			.interval(60, scheduler: MainScheduler.instance)
			.mapToVoid()

		expiredDateInterval
			.subscribeNext(weak: self, AirMapAuthSession.verifyAuthentication)
			.disposed(by: disposeBag)
	}

	/// Decode a JWT token and set the userId and expiration
	///
	/// - Parameter jwt: The JWT token to decode
	private func decodeToken(_ jwt: String) {

		if jwt.isEmpty {
			self.authToken = nil
			self.userId = ""
		}

		guard let decoded = try? JWTDecode.decode(jwt: jwt) else {
			delegate?.airmapSessionShouldAuthenticate()
			return
		}

		expiresAt = decoded.expiresAt
		userId = decoded.subject ?? ""

		AirMap.logger.debug("Decoded Token User Id", userId)
	}

	/// If the token is expired then ask the delegate for a new token
	private func verifyAuthentication() {

		guard let expiresAt = expiresAt else { return }

		if !hasValidCredentials() {

			if Date().greaterThanDate(expiresAt.dateBySubtractingTimeInterval(60*5)) {
				self.expiresAt = nil
			}

			delegate?.airmapSessionShouldAuthenticate()
		}
	}

	/// Checks for an expired token and returns a Boolean
	private func tokenIsExpired() -> Bool {
		guard let expiresAt = expiresAt else { return true }
		return Date().greaterThanDate(expiresAt)
	}

	/// Validates the credentials and returns a Bool
	internal func hasValidCredentials() -> Bool {
		return authToken != nil && !authToken!.isEmpty && !tokenIsExpired()
	}

	internal static func saveRefreshToken(_ token: String?) {
		if let token = token {
			A0SimpleKeychain().setString(token, forKey: Config.AirMapApi.Auth.keychainKeyRefreshToken)
		} else {
			A0SimpleKeychain().deleteEntry(forKey: Config.AirMapApi.Auth.keychainKeyRefreshToken)
		}
	}

	internal func getRefreshToken() -> String? {
		return A0SimpleKeychain().string(forKey: Config.AirMapApi.Auth.keychainKeyRefreshToken)
	}
}
