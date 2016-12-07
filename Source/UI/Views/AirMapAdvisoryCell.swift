//
//  AirMapAdvisoryCell.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 10/25/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit
import libPhoneNumber_iOS

class AirMapAdvisoryCell: UITableViewCell, Dequeueable, ObjectAssignable {

	typealias ObjectType = AirMapStatusAdvisory
	
	@IBOutlet weak var organizationName: UILabel?
	@IBOutlet weak var advisoryName: UILabel!
	@IBOutlet weak var type: UILabel?
	@IBOutlet weak var colorView: UIView!
    @IBOutlet weak var phone: UITextView!
    @IBOutlet weak var starts: UILabel!
    @IBOutlet weak var ends: UILabel!
    
	func setObject(object: ObjectType?) {
		advisory = object
		configure()
	}

	private var advisory: AirMapStatusAdvisory!
	
	private func configure() {
		
		organizationName?.text = advisory.organization?.name
		advisoryName.text = advisory.name
        type?.text = advisory.type?.title
        starts?.text = ""
        ends?.text = ""
        phone?.text = UIConstants.Instructions.noPhoneNumberProvided
        colorView.backgroundColor = advisory.color.colorRepresentation
        
        // TFRS
        if let trfs = advisory.tfrProperties {

            if let effectiveDate = trfs.startTime {
                starts?.text = "Starts: \(effectiveDate.shortDateString())"
            }
            if let expireDate = trfs.endTime {
                ends?.text = "Ends: \(expireDate.shortDateString())"
            } else {
                ends?.text = "Permanent"
            }
        }
        
        // Wildfires
        else if let wildfires = advisory.wildfireProperties {
            
            if let dateEffective = wildfires.dateEffective {
                starts?.text = dateEffective.shortDateString()
            }
            
            if let size = wildfires.size {
                ends?.text = "\(size) Acres"
            } else {
                ends?.text = "Size Unknown"
            }
        }
        
        // Airport
        else if let properties = advisory.airportProperties {
			
			if let phoneTxt = properties.phone where !phoneTxt.isEmpty {
				phone?.text = phoneStringFromE164(phoneTxt)
            }
        }
        
        // Phone
        if let properties = advisory.requirements?.notice {
            
            if let phoneTxt = properties.phoneNumber {
                phone?.text = phoneStringFromE164(phoneTxt)
            }
            
            if properties.digital  {
                phone?.text = "Accepts Digital Notice"
            }
        }
        
        
	}
    
   private func phoneStringFromE164(number: String) -> String? {
        do {
            let util = AirMapFlightNoticeCell.phoneUtil
            let phoneNumberObject = try util.parse(number, defaultRegion: nil)
            return try util.format(phoneNumberObject, numberFormat: NBEPhoneNumberFormat.NATIONAL)
        } catch {
            return number
        }
    }
	
}
