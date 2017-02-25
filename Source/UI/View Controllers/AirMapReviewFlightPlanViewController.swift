//
//  AirMapReviewFlightPlanViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/25/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Mapbox
import RxSwift

class AirMapReviewFlightPlanViewController: UIViewController, UIScrollViewDelegate, TabSelectorDelegate, AnalyticsTrackable {
	
	var screenName = "Create Flight - Review"
	
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
	
	fileprivate var embeddedViews = [(title: String, view: UIView)]()
	fileprivate let mapViewDelegate = AirMapMapboxMapViewDelegate()
	fileprivate let activityIndicator = ActivityIndicator()
	fileprivate let disposeBag = DisposeBag()
	
	override var navigationController: AirMapFlightPlanNavigationController? {
		return super.navigationController as? AirMapFlightPlanNavigationController
	}
	
	enum Segue: String {
		case embedFlightDetails
		case embedPermits
		case embedNotice
		case embedStatuses
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		setupBindings()
		setupEmbeddedViews()
		
		mapView.delegate = mapViewDelegate
		mapView.configure(layers: navigationController?.mapLayers ?? [], theme: navigationController?.mapTheme ?? .light)
		
		let flight: AirMapFlight
		if existingFlight != nil {
			flight = existingFlight.value
			navigationItem.title = NSLocalizedString("REVIEW_FLIGHT_PLANE_TITLE", bundle: AirMapBundle.core, value: "Flight Plan", comment: "Title for the flight plan review view")
		} else {
			flight = navigationController!.flight.value
			navigationItem.leftBarButtonItem = nil
		}
		
		if let annotations = flight.annotationRepresentations() {
			mapView.addAnnotations(annotations)
			DispatchQueue.main.async {
				self.mapView.showAnnotations(annotations, edgePadding: UIEdgeInsetsMake(10, 40, 10, 40), animated: true)
			}
		}
	}
	
	override var canBecomeFirstResponder : Bool {
		return true
	}
	
	override var inputView: UIView? {
		if existingFlight == nil {
			return submitButton
		} else if existingFlight.value.flightType() == .active {
			return endFlightButton
		} else {
			return nil
		}
	}
	
	fileprivate func setupBindings() {
	
		activityIndicator.asObservable()
			.throttle(0.25, scheduler: MainScheduler.instance)
			.distinctUntilChanged()
			.bindTo(rx_loading)
			.disposed(by: disposeBag)
	}

	fileprivate func setupEmbeddedViews() {

		let detailsTitle = NSLocalizedString("REVIEW_FLIGHT_PLAN_TAB_TITLE_FLIGHT", bundle: AirMapBundle.core, value: "Flight", comment: "Title for the Review Flight, flight Details tab")
		embeddedViews.append((title: detailsTitle, view: detailsView))

		if let status = navigationController?.status.value {
			
			if status.requiresPermits {
				let permitsTitle = NSLocalizedString("REVIEW_FLIGHT_PLAN_TAB_TITLE_PERMITS", bundle: AirMapBundle.core, value: "Permits", comment: "Title for the Review Flight, permits tab")
				embeddedViews.append((title: permitsTitle, view: permitsView))
			}
			if status.supportsDigitalNotice {
				let noticesTitle = NSLocalizedString("REVIEW_FLIGHT_PLAN_TAB_TITLE_DIGITAL_NOTICE", bundle: AirMapBundle.core, value: "Notices", comment: "Title for the Review Flight, digital notices tab")
				embeddedViews.append((title: noticesTitle, view: noticesView))
			}
			
		} else if (existingFlight?.value.statuses.count ?? 0) > 0 {
			let noticeStatusTitle = NSLocalizedString("REVIEW_FLIGHT_PLAN_TAB_TITLE_NOTICE_STATUS", bundle: AirMapBundle.core, value: "Notice Status", comment: "Title for the Review Flight, notice status tab")
			embeddedViews.append((title: noticeStatusTitle, view: statusesView))
		}

		embeddedViews.forEach { scrollView.addSubview($0.view) }
		tabView.items = embeddedViews.map { $0.title }
		tabView.delegate = self
	}

	func tabSelectorDidSelectItemAtIndex(_ index: Int) {
		
		let view = embeddedViews[index].view
		switch view {
		case detailsView:
			trackEvent(.slide, label: "Review Details Tab")
		case noticesView:
			trackEvent(.slide, label: "Review Permits Tab")
		case permitsView:
			trackEvent(.slide, label: "Review Notices Tab")
		default:
			break
		}
		scrollToTabIndex(index)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let identifier = segue.identifier else { return }

		switch Segue(rawValue: identifier)! {

		case .embedFlightDetails:
			let flightDetailsVC = segue.destination as! AirMapReviewFlightDetailsViewController
				flightDetailsVC.flight = existingFlight ?? navigationController?.flight

		case .embedPermits:
			let permitsVC = segue.destination as! AirMapReviewPermitsViewController
			if let permits = navigationController?.selectedPermits.value {
				permitsVC.selectedPermits.value = permits
			}

		case .embedNotice:
			let noticeVC = segue.destination as! AirMapReviewNoticeViewController
			noticeVC.status = navigationController?.status.value
			
		case .embedStatuses:
			let statusesVC = segue.destination as! AirMapStatusesViewController
			if let flight = existingFlight {
				statusesVC.flight = flight
			}
		}
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		let frame = scrollView.bounds
		let tabCount = CGFloat(embeddedViews.count)

		for (index, embeddedView) in embeddedViews.enumerated() {
			embeddedView.view.frame = frame
			embeddedView.view.frame.origin.x = frame.width * CGFloat(index)
		}
		scrollView.contentSize.width = frame.width * tabCount
		tabSelectionIndicatorWidthConstraint.constant = frame.width / tabCount
	}

	@IBAction func submitFlightPlan() {

		trackEvent(.tap, label: "Save")
		
		let flow = navigationController!
		let selectedPermits = flow.selectedPermits.value.map { _, availablePermit, pilotPermit in
			return (availablePermit: availablePermit, pilotPermit: pilotPermit)
		}
		let neededPermits = selectedPermits.filter { $0.pilotPermit.id.isEmpty }
		let existingPermits = selectedPermits.filter { !$0.pilotPermit.id.isEmpty }
		let existingPermitIds = existingPermits.map { $0.pilotPermit.id }

		let flight: Observable<AirMapFlight>

		if neededPermits.count > 0 {
			let permitRequests = neededPermits.map {
				AirMap.rx.apply(for: $0.availablePermit)
					.do(
						onError: { [unowned self] error in
							self.trackEvent(.save, label: "Apply Permit Error", value: NSNumber(value: (error as NSError).code)) },
						onCompleted: {
							self.trackEvent(.save, label: "Apply Permit Success") }
					)
					.trackActivity(activityIndicator)
			}
			
			let permits = Observable.zip(permitRequests, { $0 })
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
			.flatMap { [unowned self] flight in
				AirMap.rx.createFlight(flight).trackActivity(self.activityIndicator)
					.do(onError: { [unowned self] error in
						self.trackEvent(.save, label: "Create Flight Error", value: NSNumber(value: (error as NSError).code)) },
					    onCompleted: {
							self.trackEvent(.save, label: "Create Flight Success") }
					)
			}
			.subscribe(
				onNext: { [weak flow] flight in
					flow?.flightPlanDelegate.airMapFlightPlanDidCreate(flight) },
				onError: { [weak flow] error in
					flow?.flightPlanDelegate.airMapFlightPlanDidEncounter(error as NSError)
				}
			)
			.disposed(by: disposeBag)
	}
	
	@IBAction func endFlight() {
		AirMap.rx.endFlight(existingFlight.value)
			.trackActivity(activityIndicator)
			.subscribe(onCompleted: { [unowned self] _ in
				self.dismiss()
			})
			.disposed(by: disposeBag)
	}
	
	@IBAction func dismiss() {
		resignFirstResponder()
		self.dismiss(animated: true, completion: nil)
	}

	@IBAction func scrollToTabIndex(_ index: Int) {
		let offset = CGPoint(x: scrollView.frame.width * CGFloat(index), y: 0)
		scrollView.setContentOffset(offset, animated: true)
	}

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		tabSelectionIndicator.transform = CGAffineTransform(translationX: scrollView.contentOffset.x / CGFloat(embeddedViews.count), y: 0)
	}
		
}
