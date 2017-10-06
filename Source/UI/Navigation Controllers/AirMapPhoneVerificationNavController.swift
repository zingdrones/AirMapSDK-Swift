//
//  AirMapPhoneVerificationNavController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/23/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

public protocol AirMapPhoneVerificationDelegate: class {
	func phoneVerificationDidVerifyPhoneNumber(verifiedPhoneNumber:String?)
}

open class AirMapPhoneVerificationNavController: UINavigationController {
	weak var phoneVerificationDelegate: AirMapPhoneVerificationDelegate?
}
