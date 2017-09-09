//
//  LoginExampleViewController.swift
//  AirMapSDK-Example-iOS
//
//  Created by Adolfo Martinelli on 9/8/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import UIKit
import AirMap

class LoginExampleViewController: UIViewController {

	@IBOutlet var pilotInfo: UILabel!
	@IBOutlet var loginButton: UIButton!
	
	@IBAction func login() {
		
		// Present a login UI from the current the view controller
		AirMap.login(from: self) { (result: Result<AirMapPilot>) in
			
			switch result {
				
			// Handle the error case
			case .error(let error):
				
				let alert = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
				self.present(alert, animated: true, completion: nil)
				
			// Handle the success case
			case .value(let pilot):
				
				let info: [(key: String, value: String?)] = [
					("First Name", pilot.firstName),
					("Last Name", pilot.lastName),
					("Username", pilot.username),
					("Email", pilot.email),
					("Email verified", pilot.emailVerified.description),
					("Phone", pilot.phone),
					("Phone verified", pilot.phoneVerified.description),
					("Total flights", pilot.statistics?.totalFlights.description),
					("Total aircraft", pilot.statistics?.totalAircraft.description),
					("Pilot ID", pilot.id)
				]
				
				// Define text style attributes
				let keyAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)]
				let valueAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 17)]
				
				// Apply the styling to the text and construct a single attributed string
				let attributedInfo = info
					.reduce(NSMutableAttributedString(), { (total, next) -> NSMutableAttributedString in
						total.append(NSAttributedString(string: next.key.uppercased(), attributes: keyAttributes))
						total.append(NSAttributedString(string: "\n"))
						total.append(NSAttributedString(string: next.value ?? "none", attributes: valueAttributes))
						total.append(NSAttributedString(string: "\n\n"))
						return total
					})
				
				self.pilotInfo.attributedText = attributedInfo
				self.loginButton.isHidden = true
			}
		}
	}
}
