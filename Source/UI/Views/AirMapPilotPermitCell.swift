//
//  AirMapPilotPermitCell.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 10/31/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit

class AirMapPilotPermitCell: UITableViewCell, Dequeueable, ObjectAssignable {
	
	typealias ObjectType = AirMapPilotPermit

	@IBOutlet weak var permitTitle: UILabel!
	@IBOutlet weak var PermitDescription: UILabel!
	@IBOutlet weak var permitStatus: UILabel!
	
	private var availablePermit: ObjectType!
	
	func setObject(object: ObjectType?) {
		availablePermit = object
	}
	

}
