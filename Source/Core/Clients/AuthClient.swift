//
//  AuthClient.swift
//  Pods
//
//  Created by Rocky Demoff on 8/9/16.
//
//

import RxSwift

internal class AirMapAuthClient: HTTPClient {

	init() {
		super.init(Config.AirMapApi.Auth.ssoUrl)
	}

	func refreshAccessToken() -> Observable<AirMapToken> {
		AirMap.logger.debug("Refresh Access Token")

		guard let refreshToken = AirMap.authSession.getRefreshToken() else {
			return Observable.error(AirMapErrorType.Unauthorized)
		}

		let params = ["grant_type" : Config.AirMapApi.Auth.grantType,
		                  "client_id" : AirMap.configuration.auth0ClientId,
		                  "api_type" : "app",
		                  "refresh_token" : refreshToken]

		return call(.POST, url:"/delegation", params: params, keyPath: nil)
			.doOnNext { token in
				AirMap.authToken = token.authToken
//				AirMap.rx_getAuthenticatedPilot()
//					.subscribeNext { pilot in
//						AirMap.authSession.delegate?.airMapAuthSessionDidAuthenticate?(pilot)
//					}
			}
		}

}
