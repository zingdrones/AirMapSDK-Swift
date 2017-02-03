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
		super.init(basePath: Config.AirMapApi.permitUrl)
	}

	func list(_ permitIds: [String]? = nil, organizationId: String? = nil) -> Observable<[AirMapAvailablePermit]> {
		AirMap.logger.debug("Get Permit", permitIds, organizationId)

		var params = [String : Any]()
		params["ids"] = permitIds?.joined(separator: ",")
		params["organization_id"] = organizationId

		return perform(method: .get, params: params)
	}

	func apply(for permit: AirMapAvailablePermit) -> Observable<AirMapPilotPermit> {
		AirMap.logger.debug("Apply for Permit", permit)
		return perform(method: .post, path:"/\(permit.id)/apply", params: permit.params())
	}
}
