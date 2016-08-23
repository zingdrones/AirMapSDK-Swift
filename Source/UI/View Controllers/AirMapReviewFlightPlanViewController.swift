//
//  AirMapReviewFlightPlanViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/25/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Mapbox
import RxSwift

class AirMapReviewFlightPlanViewController: UIViewController, UIScrollViewDelegate, TabSelectorDelegate {
	
	@IBOutlet weak var mapView: AirMapMapView!
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var tabView: TabSelectorView!
	@IBOutlet weak var tabSelectionIndicator: UIView!
	@IBOutlet weak var tabSelectionIndicatorWidthConstraint: NSLayoutConstraint!
	@IBOutlet var submitButton: UIButton!
	@IBOutlet var endFlightButton: UIButton!

	@IBOutlet var detailsView: UIView!
	@IBOutlet var permitsView: UIView!
	@IBOutlet var noticesView: UIView!
	@IBOutlet var statusesView: UIView!

	var existingFlight: Variable<AirMapFlight>!
	
	private var embeddedViews = [(title: String, view: UIView)]()
	private let disposeBag = DisposeBag()
	private let mapViewDelegate = AirMapMapboxMapViewDelegate()

	override var navigationController: AirMapFlightPlanNavigationController? {
		return super.navigationController as? AirMapFlightPlanNavigationController
	}
	
	enum Segue: String {
		case embedFlightDetails
		case embedPermits
		case embedNotice
		case embedStatuses
		case modalFAQ
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		setupEmbeddedViews()
		
		mapView.delegate = mapViewDelegate
		mapViewDelegate.status = navigationController?.status.value

		let flight: AirMapFlight
		
		if existingFlight != nil {
			flight = existingFlight.value
		} else {
			flight = navigationController!.flight.value
		}

		let polygon = AirMapFlightRadiusAnnotation.polygon(flight.coordinate, radius: flight.buffer!)
		mapView.addAnnotations([flight, polygon])
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		let insets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
		mapView.showAnnotations(mapView.annotations!, edgePadding: insets, animated: false)
	}
	
	override func canBecomeFirstResponder() -> Bool {
		return true
	}
	
	override var inputView: UIView? {
		if existingFlight == nil {
			return submitButton
		} else if existingFlight.value.flightType() == .Active {
			return endFlightButton
		} else {
			return nil
		}
	}

	private func setupEmbeddedViews() {

		embeddedViews.append((title: "Flight", view: detailsView))

		if let status = navigationController?.status.value {
			
			if status.numberOfRequiredPermits > 0 {
				embeddedViews.append((title: "Permits", view: permitsView))
			}
			if status.numberOfNoticesRequired > 0 {
				embeddedViews.append((title: "Notices", view: noticesView))
			}
			
		} else if existingFlight?.value.statuses.count > 0 {
			embeddedViews.append((title: "Notice Status", view: statusesView))
		}

		embeddedViews.forEach { scrollView.addSubview($0.view) }
		tabView.items = embeddedViews.map { $0.title }
		tabView.delegate = self
	}

	func tabSelectorDidSelectItemAtIndex(index: Int) {
		scrollToTabIndex(index)
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		guard let identifier = segue.identifier else { return }

		switch Segue(rawValue: identifier)! {

		case .embedFlightDetails:
			let flightDetailsVC = segue.destinationViewController as! AirMapReviewFlightDetailsViewController
				flightDetailsVC.flight = existingFlight ?? navigationController?.flight

		case .embedPermits:
			let permitsVC = segue.destinationViewController as! AirMapReviewPermitsViewController
			if let permits = navigationController?.selectedPermits.value {
				permitsVC.selectedPermits.value = permits
			}

		case .embedNotice:
			let noticeVC = segue.destinationViewController as! AirMapReviewNoticeViewController
			noticeVC.status = navigationController?.status.value
			
		case .embedStatuses:
			let statusesVC = segue.destinationViewController as! AirMapStatusesViewController
			if let flight = existingFlight {
				statusesVC.flight = flight
			}
			
		case .modalFAQ:
			let nav = segue.destinationViewController as! UINavigationController
			let faqVC = nav.viewControllers.last as! AirMapFAQViewController
			faqVC.section = .LetOthersKnow
		}
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		let frame = scrollView.bounds
		let tabCount = CGFloat(embeddedViews.count)

		for (index, embeddedView) in embeddedViews.enumerate() {
			embeddedView.view.frame = frame
			embeddedView.view.frame.origin.x = frame.width * CGFloat(index)
		}
		scrollView.contentSize.width = frame.width * tabCount
		tabSelectionIndicatorWidthConstraint.constant = frame.width / tabCount
	}

	@IBAction func submitFlightPlan() {

		let flow = navigationController!
		let selectedPermits = flow.selectedPermits.value.map { _, availablePermit, pilotPermit in
			return (availablePermit: availablePermit, pilotPermit: pilotPermit)
		}
		let neededPermits = selectedPermits.filter { $0.pilotPermit.id.isEmpty }
		let existingPermits = selectedPermits.filter { !$0.pilotPermit.id.isEmpty }
		let existingPermitIds = existingPermits.map { $0.pilotPermit.id }

		let flight: Observable<AirMapFlight>

		if neededPermits.count > 0 {
			let permitRequests = neededPermits.map { AirMap.rx_applyForPermit($0.availablePermit) }
			let permits = permitRequests.zip { $0 }
			let permitIds = permits.map { $0.map { $0.id } }
			flight = permitIds.map { ids -> AirMapFlight in
				flow.flight.value.permitsIds = ids + existingPermitIds
				return flow.flight.value
			}
		} else {
			flow.flight.value.permitsIds = existingPermitIds
			flight = Observable.just(flow.flight.value)
		}

		flight
			.flatMap { AirMap.rx_createFlight($0) }
			.doOnError { [weak flow] error in flow?.flightPlanDelegate.airMapFlightPlanDidEncounter(error as NSError) }
			.subscribeNext { [weak flow] flight in
				flow?.flightPlanDelegate.airMapFlightPlanDidCreate(flight)
			}
			.addDisposableTo(disposeBag)
	}
	
	@IBAction func endFlight() {
		AirMap.rx_endFlight(existingFlight.value)
			.doOnCompleted { [unowned self] _ in
				self.dismiss()
		}
		.subscribe()
		.addDisposableTo(disposeBag)
	}
	
	@IBAction func dismiss() {
		resignFirstResponder()
		dismissViewControllerAnimated(true, completion: nil)
	}

	@IBAction func scrollToTabIndex(index: Int) {

		let offset = CGPoint(x: scrollView.frame.width * CGFloat(index), y: 0)
		scrollView.setContentOffset(offset, animated: true)
	}

	func scrollViewDidScroll(scrollView: UIScrollView) {
		tabSelectionIndicator.transform = CGAffineTransformMakeTranslation(scrollView.contentOffset.x / CGFloat(embeddedViews.count), 0)
	}
}
