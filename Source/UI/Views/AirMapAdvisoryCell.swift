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
	
	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var type: UILabel!
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
        
        if let organization = advisory.organization {
            name.text = (advisory.type != .Airport) ? organization.name : advisory.name
        } else {
            name.text = advisory.name
        }
        
        type.text = advisory.type?.title
        starts?.text = ""
        ends?.text = ""
        phone?.text = ""
        colorView.backgroundColor = advisory.color.colorRepresentation
        
        // TFRS
        if let trfs = advisory.tfrProperties {

            if let effectiveDate = trfs.startTime {
                starts?.text = "Starts: \(effectiveDate.shortDateString())"
            }
            if let expireDate = trfs.endTime {
                ends?.text = "Ends: \(expireDate.shortDateString())"
            } else {
                ends?.text = "Ends: Permanent"
            }
        }
        
        // Wildfires
        if let wildfires = advisory.wildfireProperties {
            
            if let dateEffective = wildfires.dateEffective {
                starts?.text = dateEffective.shortDateString()
            }
            
            if let size = wildfires.size {
                ends?.text = "\(size) Acres"
            } else {
                ends?.text = "Unknown"
            }
        }
        
        // Airport
        if let properties = advisory.airportProperties {
            if let phoneTxt = properties.phone {
                phone?.text = (phoneTxt.characters.count > 0) ? phoneStringFromE164(phoneTxt) : "PHONE NUMBER NOT PROVIDED"
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
	
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
