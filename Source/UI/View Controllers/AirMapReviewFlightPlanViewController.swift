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

	@IBOutlet var detailsView: UIView!
	@IBOutlet var permitsView: UIView!
	@IBOutlet var noticesView: UIView!

	private var embeddedViews = [(title: String, view: UIView)]()
	private let disposeBag = DisposeBag()

	override var navigationController: AirMapFlightPlanNavigationController? {
		return super.navigationController as? AirMapFlightPlanNavigationController
	}

	enum Segue: String {
		case embedFlightDetails
		case embedPermits
		case embedNotice
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		setupEmbeddedViews()
	}

	func setupEmbeddedViews() {

		embeddedViews.append((title: "Flight", view: detailsView))

		let status = navigationController!.status.value!

		if status.numberOfRequiredPermits > 0 {
			embeddedViews.append((title: "Permits", view: permitsView))
		}
		if status.numberOfNoticesRequired > 0 {
			embeddedViews.append((title: "Notices", view: noticesView))
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
			flightDetailsVC.flight = navigationController!.flight

		case .embedPermits:
			let permitsVC = segue.destinationViewController as! AirMapReviewPermitsViewController
			permitsVC.selectedPermits.value = navigationController!.selectedPermits.value

		case .embedNotice:
			let noticeVC = segue.destinationViewController as! AirMapReviewNoticeViewController
			noticeVC.status = navigationController!.status.value
		}
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		let flight = navigationController!.flight.value
		let polygon = AirMapFlightRadiusAnnotation.polygon(flight.coordinate, radius: flight.buffer!)
		self.mapView.addAnnotation(polygon)
		let insets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
		self.mapView.showAnnotations([polygon], edgePadding: insets, animated: false)
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
			.flatMap { flight in
				AirMap.rx_createFlight(flight)
					.doOnError(flow.flightPlanDelegate.airMapFlightPlanDidEncounter)
			}
			.doOnError(flow.flightPlanDelegate.airMapFlightPlanDidEncounter)
			.subscribeNext(flow.flightPlanDelegate.airMapFlightPlanDidCreate)
			.addDisposableTo(disposeBag)
	}

	@IBAction func scrollToTabIndex(index: Int) {


		let offset = CGPoint(x: scrollView.frame.width * CGFloat(index), y: 0)
		scrollView.setContentOffset(offset, animated: true)
	}

	func scrollViewDidScroll(scrollView: UIScrollView) {
		tabSelectionIndicator.transform = CGAffineTransformMakeTranslation(scrollView.contentOffset.x / CGFloat(embeddedViews.count), 0)
	}
}

extension AirMapReviewFlightPlanViewController: MGLMapViewDelegate {


	func mapView(mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
		return UIColor(red: 252.0/255.0, green: 76.0/255.0, blue: 2.0/255.0, alpha: 0.75)
	}

	func mapView(mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
		return 8.0
	}

	func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
		return .redColor()
	}

}
