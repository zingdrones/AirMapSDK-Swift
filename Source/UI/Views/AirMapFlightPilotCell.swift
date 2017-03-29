//
//  AirMapFlightPilotCell.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/18/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class AirMapFlightPilotCell: UITableViewCell, Dequeueable {
	
	@IBOutlet weak var pilotLabel: UILabel!
	
	static let reuseIdentifier = String(describing: AirMapFlightPilotCell.self)
	
	var pilot = Variable(nil as AirMapPilot?) {
		didSet { setupBindings() }
	}

	fileprivate let disposeBag = DisposeBag()
	
	fileprivate func setupBindings() {
		
		pilot
			.asObservable()
			.subscribeOn(MainScheduler.instance)
			.unwrap()
			.map { [unowned self] pilot in self.fullName(pilot.firstName, lastName: pilot.lastName) }
			.bindTo(pilotLabel!.rx.text)
			.disposed(by: disposeBag)
	}
	
	fileprivate func fullName(_ firstName: String?, lastName: String?) -> String {
		return [firstName, lastName].flatMap {$0}.joined(separator: " ")
	}
	
}
