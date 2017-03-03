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
		
		let localized = LocalizedStrings.Advisory.self
		organizationName?.text = advisory.organization?.name
		advisoryName.text = advisory.name
        type?.text = advisory.type?.title
        starts?.text = ""
        ends?.text = ""
		phone?.text = localized.phoneNumberNotProvided

		phone?.isUserInteractionEnabled = false
        colorView.backgroundColor = advisory.color.colorRepresentation
        
        // TFRS
        if let trfs = advisory.tfrProperties {

            if let effectiveDate = trfs.startTime {
				starts?.text = String(format: localized.tfrStartsFormat, effectiveDate.shortDateString())
            }
            if let expireDate = trfs.endTime {
                ends?.text = String(format: localized.tfrStartsFormat, expireDate.shortDateString())
            } else {
                ends?.text
            }
        }
        
        // Wildfires
        else if let wildfires = advisory.wildfireProperties {
            
            if let dateEffective = wildfires.dateEffective {
                starts?.text = dateEffective.shortDateString()
            }
            
            if let size = wildfires.size {
				switch AirMap.configuration.distanceUnits {
				case .metric:
					ends?.text = String(format: localized.wildfireSizeFormatHectares, size)
				case .imperial:
					ends?.text = String(format: localized.wildfireSizeFormatAcres, size)
				}
            } else {
                ends?.text = localized.wildfireSizeUnknown
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
                phone?.text = localized.acceptsDigitalNotice
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
