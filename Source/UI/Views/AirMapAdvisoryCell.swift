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
    @IBOutlet weak var phone: AirMapPhoneTextView?
    @IBOutlet weak var starts: UILabel!
    @IBOutlet weak var ends: UILabel!
    
	func setObject(_ object: ObjectType?) {
		advisory = object
		configure()
	}

	fileprivate var advisory: AirMapStatusAdvisory!
	
	fileprivate func configure() {
		
		organizationName?.text = advisory.organization?.name
		advisoryName.text = advisory.name
        type?.text = advisory.type?.title
        starts?.text = ""
        ends?.text = ""
		phone?.text = NSLocalizedString("ADVISORY_CELL_PHONE_NOT_PROVIDED", bundle: AirMapBundle.core, value: "No Phone Number Provided", comment: "Displayed when an advisory has not provided a contact phone")

		phone?.isUserInteractionEnabled = false
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
				let wildfireFormat = NSLocalizedString("ADVISORY_CELL_WILDFIRE_SIZE_FORMAT", bundle: AirMapBundle.core, value: "%$1i Acres", comment: "Label and format for wildfire advisory cells")
				ends?.text = String(format: wildfireFormat, size)
            } else {
				let sizeUnknown = NSLocalizedString("ADVISORY_CELL_WILDFIRE_SIZE_UNKNOWN", bundle: AirMapBundle.core, value: "Size Unknown", comment: "Label for wildfire advisory cells where size is unknown")
                ends?.text = sizeUnknown
            }
        }
        
        // Airport
        else if let properties = advisory.airportProperties {
			
			if let phoneTxt = properties.phone, !phoneTxt.isEmpty {
				phone?.text = phoneStringFromE164(phoneTxt)
				phone?.isUserInteractionEnabled = true
            }
        }
        
        // Phone
        if let properties = advisory.requirements?.notice {
            
            if let phoneTxt = properties.phoneNumber {
                phone?.text = phoneStringFromE164(phoneTxt)
				phone?.isUserInteractionEnabled = true
            }
            
            if properties.digital  {
                phone?.text = NSLocalizedString("ADVISORY_CELL_ACCEPTS_DIGITAL_NOTICE", bundle: AirMapBundle.core, value: "Accepts Digital Notice", comment: "Label for advisories that are stup to receive digital notice")
            }
        }
        
        
	}
    
   fileprivate func phoneStringFromE164(_ number: String) -> String? {
        do {
            let util = AirMapFlightNoticeCell.phoneUtil
            let phoneNumberObject = try util.parse(number, defaultRegion: nil)
            return try util.format(phoneNumberObject, numberFormat: NBEPhoneNumberFormat.NATIONAL)
        } catch {
            return number
        }
    }
	
}
