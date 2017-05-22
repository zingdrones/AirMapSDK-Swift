//
//  AirMapFlightBriefViewController.swift
//  AirMap
//
//  Created by Adolfo Martinelli on 5/21/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import FZAccordionTableView

public class AirMapFlightBriefViewController: UITableViewController {
	
	let briefingVar = Variable(nil as AirMapFlightBriefing?)
	
	enum BriefingSection {
		case conflicting
		case needingMoreInfo
		case needingReview
		case notConflicting
		
		var title: String {
			switch self {
			case .conflicting:
				return "Rules you are violating"
			case .needingMoreInfo:
				return "Rules needing more information"
			case .needingReview:
				return "Rules you should review"
			case .notConflicting:
				return "Rules you are following"
			}
		}
		
		var icon: UIImage {
			switch self {
			case .conflicting:
				return AirMapImage.image(named: "rules_conflicting_icon")!
			case .needingMoreInfo:
				return AirMapImage.image(named: "rules_need_more_info_icon")!
			case .needingReview:
				return AirMapImage.image(named: "rules_to_review_icon")!
			case .notConflicting:
				return AirMapImage.image(named: "rules_not_conflicting_icon")!
			}
		}
	}
	
	private typealias BriefingSectionModel = SectionModel<BriefingSection,AirMapRule>
	private let dataSource = RxTableViewSectionedReloadDataSource<BriefingSectionModel>()
	private let disposeBag = DisposeBag()
	
	// MARK: - View Lifecycle
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		setupBindings()
	}
	
	// MARK: - Setup
	
	private func setupBindings() {
		
		briefingVar.asObservable()
			.subscribe()
			.disposed(by: disposeBag)
	}
	
	// MARK: - IBActions
	
	@IBAction func dismiss() {
		dismiss(animated: true, completion: nil)
	}
	
//	private static func sectionModels() -> {
//		
//	}
}

class BriefHeaderView: FZAccordionTableViewHeaderView {
	
	
	
}
