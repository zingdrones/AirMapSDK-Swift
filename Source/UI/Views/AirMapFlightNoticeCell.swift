//
//  AirMapFlightNoticeCell.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/21/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import libPhoneNumber_iOS

class AirMapFlightNoticeCell: UITableViewCell {
	
	static let phoneUtil = NBPhoneNumberUtil()
	
	var advisory: AirMapStatusAdvisory! {
		didSet {
            
            if let organization = advisory.organization {
                name.text = (advisory.type != .Airport) ? organization.name : advisory.name
            } else {
                name.text = advisory.name
            }
            
            
            let phoneStr = phoneStringFromE164(advisoryPhoneNumber) ?? UIConstants.Instructions.noPhoneNumberProvided
            phoneNumber?.text = phoneStr
		}
	}

	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var phoneNumber: UITextView?
	
	private var advisoryPhoneNumber: String? {
		return advisory.requirements?.notice?.phoneNumber
	}
	
	private func phoneStringFromE164(number: String?) -> String? {
		
		let util = AirMapFlightNoticeCell.phoneUtil
		if let number = number,
			phoneNumberObject = try? util.parse(number, defaultRegion: nil),
			displayString = try? util.format(phoneNumberObject, numberFormat: NBEPhoneNumberFormat.NATIONAL) {
			return displayString
		} else {
			return number
		}
	}
	
}
