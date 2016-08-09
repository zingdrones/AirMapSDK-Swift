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
			name.text = advisory.name
			phoneNumber?.setTitle(phoneStringFromE164(advisoryPhoneNumber), forState: .Normal)
		}
	}

	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var phoneNumber: UIButton?
	
	private var advisoryPhoneNumber: String? {
		return advisory.requirements?.notice?.phoneNumber
	}
	
	@IBAction func callAdvisoryAuthority() {
		
		let application = UIApplication.sharedApplication()
		
		guard
			let url = NSURL(string: "telprompt://\(advisoryPhoneNumber)")
			where application.canOpenURL(url)
			else { return }
		
		application.openURL(url)
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