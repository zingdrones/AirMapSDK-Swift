//
//  AirMapFlightAircraftCell.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/18/16.
//  Copyright 2018 AirMap, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import RxSwift
import RxCocoa

class AirMapFlightAircraftCell: UITableViewCell, Dequeueable {
	
	static let reuseIdentifier = String(describing: AirMapFlightAircraftCell.self)
	
	@IBOutlet weak var selectedAircraft: UILabel!

	let aircraft = BehaviorRelay<AirMapAircraft?>(value: nil)
	fileprivate let disposeBag = DisposeBag()
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		setupBindings()
	}
	
	fileprivate func setupBindings() {
		
		aircraft
			.subscribeOn(MainScheduler.instance)
			.map {
				let selectAircraftTitle = LocalizedStrings.Aircraft.selectAircraft
				return $0?.nickname ?? selectAircraftTitle
			}
			.bind(to: selectedAircraft.rx.text)
			.disposed(by: disposeBag)
	}
}
