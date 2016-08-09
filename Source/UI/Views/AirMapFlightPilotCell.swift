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
	
	static let reuseIdentifier = String(AirMapFlightPilotCell)
	
	var pilot = Variable(nil as AirMapPilot?)

	private let disposeBag = DisposeBag()
	
	override func awakeFromNib() {
		super.awakeFromNib()

		setupBindings()
	}
	
	private func setupBindings() {
		
		pilot
			.asObservable()
			.subscribeOn(MainScheduler.instance)
			.unwrap()
			.map { [unowned self] pilot in self.fullName(pilot.firstName, lastName: pilot.lastName) }
			.bindTo(textLabel!.rx_text)
			.addDisposableTo(disposeBag)
	}
	
	private func fullName(firstName: String?, lastName: String?) -> String {
		return [firstName, lastName].flatMap {$0}.joinWithSeparator(" ")
	}
	
}
