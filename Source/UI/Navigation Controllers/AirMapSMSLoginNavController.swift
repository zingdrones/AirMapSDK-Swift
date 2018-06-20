//
//  AirMapSMSLoginNavController.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 3/3/17.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit

public protocol AirMapSMSLoginDelegate: class {
    func smsLoginDidAuthenticate()
    func smsLogindidFailToAuthenticate(error:Auth0Error)
}

open class AirMapSMSLoginNavController: UINavigationController {
    
    weak var smsLoginDelegate: AirMapSMSLoginDelegate?
}
