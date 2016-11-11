//
//  AirMapPilotPermitCell.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 10/31/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit

class AirMapPilotPermitCell: UITableViewCell, Dequeueable, ObjectAssignable {
	
	typealias ObjectType = (availablePermit: AirMapAvailablePermit, pilotPermit: AirMapPilotPermit?)

	@IBOutlet weak var permitTitle: UILabel!
	@IBOutlet weak var permitStatus: UILabel?
	@IBOutlet weak var permitExpiration: UILabel?
	@IBOutlet weak var permitDescription: UILabel!
	
	private var permitData: ObjectType!
	
	private static let dateFormatter: NSDateFormatter = {
		let df = NSDateFormatter()
		df.dateStyle = .MediumStyle
		df.timeStyle = .NoStyle
		return df
	}()
	
	func setObject(object: ObjectType?) {
		
		permitData = object
		configure()
	}
	
	private func configure() {

		permitTitle.text = permitData.availablePermit.name
		permitDescription.text = permitData.availablePermit.info
		permitStatus?.text = permitData.pilotPermit?.status.rawValue.capitalizedString
		if let expirationDate = permitData.pilotPermit?.expiresAt {
			permitExpiration?.text = "Expires " + AirMapPilotPermitCell.dateFormatter.stringFromDate(expirationDate)
		} else {
			permitExpiration?.text = nil
		}
	}
		
}
