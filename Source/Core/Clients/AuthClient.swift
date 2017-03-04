//
//  AuthUserClient.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 2/24/17.
//  Copyright © 2016-2017 AirMap, Inc. All rights reserved.
//

import RxSwift
import Alamofire

internal class AuthClient: HTTPClient {
    
    init() {
        super.init(basePath: Config.AirMapApi.authUrl)
    }
    
    func performAnonymousLogin(userId:String) -> Observable<AirMapToken> {
        
        let params = ["user_id": userId]
        
        return perform(method: .post, path:"/anonymous/token", params: params, keyPath: "data")
            .do(onNext: { token in
                AirMap.authToken = token.authToken
            }, onError: { error in
                AirMap.logger.debug("ERROR: \(error)")
            })
    }
}
