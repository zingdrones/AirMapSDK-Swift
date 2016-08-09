//
//  PermitClient.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/19/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift

internal class PermitClient: HTTPClient {

	init() {
		super.init(Config.AirMapApi.permitUrl)
	}

	func list(permitIds: [String]? = nil, organizationId: String? = nil) -> Observable<[AirMapAvailablePermit]> {
		AirMap.logger.info("Get Permit", permitIds, organizationId)

		var params = [String : AnyObject]()
		params["ids"] = permitIds?.joinWithSeparator(",")
		params["organization_id"] = organizationId

		return call(.GET, params: params)
	}

	func apply(permit: AirMapAvailablePermit) -> Observable<AirMapPilotPermit> {
		AirMap.logger.info("Apply for Permit", permit)
		return call(.POST, url:"/\(permit.id.urlEncoded)/apply", params: permit.params())
	}
}
