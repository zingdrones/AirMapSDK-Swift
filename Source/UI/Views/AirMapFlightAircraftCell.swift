//
//  AirMapFlightAircraftCell.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/18/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class AirMapFlightAircraftCell: UITableViewCell, Dequeueable {
	
	static let reuseIdentifier = String(AirMapFlightAircraftCell)
	
	@IBOutlet weak var selectedAircraft: UILabel!

	let aircraft = Variable(nil as AirMapAircraft?)
	private let disposeBag = DisposeBag()
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		setupBindings()
	}
	
	private func setupBindings() {
		
		aircraft
			.asObservable()
			.subscribeOn(MainScheduler.instance)
			.map { $0?.nickname ?? "Select Aircraft" }
			.bindTo(selectedAircraft.rx_text)
			.addDisposableTo(disposeBag)
	}
}