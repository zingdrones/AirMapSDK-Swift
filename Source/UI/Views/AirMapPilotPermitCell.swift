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
	@IBOutlet weak var walletIcon: UIImageView!
	@IBOutlet weak var walletIconSpacing: NSLayoutConstraint!
	
	fileprivate var permitData: ObjectType!
	
	fileprivate static let dateFormatter: DateFormatter = {
		let df = DateFormatter()
		df.dateStyle = .medium
		df.timeStyle = .none
		return df
	}()
	
	func setObject(_ object: ObjectType?) {
		
		permitData = object
		configure()
	}
	
	fileprivate func configure() {

		permitTitle.text = permitData.availablePermit.name
		permitDescription.text = permitData.availablePermit.info
		
		if let status = permitData.pilotPermit?.status {
			permitStatus?.text = status.rawValue.capitalized
		} else {
			permitStatus?.text = AirMapPilotPermit.PermitStatus.pending.rawValue.capitalized
		}
		
		if let expirationDate = permitData.pilotPermit?.expiresAt {
			let expirationString = AirMapPilotPermitCell.dateFormatter.string(from: expirationDate)
			permitExpiration?.text = String(format: LocalizedString.PilotPermit.expirationFormat, expirationString)
		} else {
			permitExpiration?.text = nil
		}
	}
		
}
