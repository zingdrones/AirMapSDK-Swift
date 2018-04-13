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

// INTERNAL

internal class AirMapAuthSession {

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
	internal var userId: AirMapPilotId = ""
	internal var expiresAt: Date!
	internal weak var delegate: AirMapAuthSessionDelegate?

	private let disposeBag = DisposeBag()

	init() {
		setupBindings()
	}

	private func setupBindings() {

		Observable<Int>
			.interval(60, scheduler: MainScheduler.instance)
			.mapToVoid()
			.subscribe(onNext: { [weak self] _ in
				self?.verifyAuthentication()
			})
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
		if let userId = decoded.subject {
			self.userId = AirMapPilotId(rawValue: userId)
		} else {
			self.userId = ""
		}

		AirMap.logger.debug("Decoded Token User Id", userId)
	}

	/// If the token is expired then ask the delegate for a new token
	private func verifyAuthentication() {

		guard let expiresAt = expiresAt else { return }

		if !hasValidCredentials() {

			if Date() > expiresAt.addingTimeInterval(-60*5) {
				self.expiresAt = nil
			}

			delegate?.airmapSessionShouldAuthenticate()
		}
	}

	/// Checks for an expired token and returns a Boolean
	private func tokenIsExpired() -> Bool {
		guard let expiresAt = expiresAt else { return true }
		return Date() > expiresAt
	}

	/// Validates the credentials and returns a Bool
	internal func hasValidCredentials() -> Bool {
		return authToken != nil && !authToken!.isEmpty && !tokenIsExpired()
	}

	internal static func saveRefreshToken(_ token: String?) {
		if let token = token {
			A0SimpleKeychain().setString(token, forKey: Constants.AirMapApi.Auth.keychainKeyRefreshToken)
		} else {
			A0SimpleKeychain().deleteEntry(forKey: Constants.AirMapApi.Auth.keychainKeyRefreshToken)
		}
	}

	internal func getRefreshToken() -> String? {
		return A0SimpleKeychain().string(forKey: Constants.AirMapApi.Auth.keychainKeyRefreshToken)
	}
}
