//
//  StatusTests.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/1/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

@testable import AirMap
import Mockingjay
import Nimble
import RxSwift

class StatusTests: TestCase {

	let disposeBag = DisposeBag()

	func testGetPointStatus() {

		stub(.GET, Config.AirMapApi.statusUrl + "point", with: "status_get_point_success.json")

		waitUntil { done in

			let whiteHouseCoordinate = CoordinateFactory.whiteHouseCoordinate()

			AirMap.rx_checkCoordinate(whiteHouseCoordinate, buffer: 500)
				.doOnNext { status in
					expect(status.maxSafeDistance).to(equal(0))
					expect(status.advisories.count).to(equal(23))
					expect(status.advisoryColor).to(equal(AirMapStatus.StatusColor.Red))
				}
				.doOnError { expect($0).to(beNil()); done() }
				.doOnCompleted(done)
				.subscribe()
				.addDisposableTo(self.disposeBag)
		}
	}

	func testGetFlightPathStatus() {

		stub(.GET, Config.AirMapApi.statusUrl + "path", with: "status_get_path_success.json")

		waitUntil { done in

			let path = [
				CoordinateFactory.ksmoCoordinate(),
				CoordinateFactory.santaMonicaPierCoordinate()
			]

			AirMap.rx_checkFlightPath(path, buffer: 100, takeOffPoint: path.first!)
				.doOnNext { status in
					expect(status.maxSafeDistance).to(equal(0))
					expect(status.advisories.count).to(equal(19))
					expect(status.advisoryColor).to(equal(AirMapStatus.StatusColor.Green))
				}
				.doOnError { expect($0).to(beNil()); done() }
				.doOnCompleted(done)
				.subscribe()
				.addDisposableTo(self.disposeBag)
		}
	}

	func testGetFlightPolygonStatus() {

		stub(.GET, Config.AirMapApi.statusUrl + "polygon", with: "status_get_polygon_success.json")

		waitUntil { done in

			let polygon = CoordinateFactory.marinaDelReyMarinaPolygonCoordinates()

			AirMap.rx_checkPolygon(polygon, takeOffPoint: polygon.first!)
				.doOnNext { status in
					expect(status.maxSafeDistance).to(equal(0))
					expect(status.advisories.count).to(equal(17))
					expect(status.advisoryColor).to(equal(AirMapStatus.StatusColor.Green))
				}
				.doOnError { expect($0).to(beNil()); done() }
				.doOnCompleted(done)
				.subscribe()
				.addDisposableTo(self.disposeBag)
		}
	}

	func testWeatherStatus() {

		stub(.GET, Config.AirMapApi.statusUrl + "point", with: "status_weather_success.json")

		waitUntil { done in

			let whiteHouseCoordinate = CoordinateFactory.whiteHouseCoordinate()

			AirMap.rx_checkCoordinate(whiteHouseCoordinate, buffer: 500, weather: true)
				.doOnNext { status in
					guard let weather = status.weather else {
						expect(status.weather).toNot(beNil()); return
					}
					expect(weather.temperature).to(equal(23))
					expect(weather.condition).to(equal("Mostly Sunny"))
					expect(weather.visibility).to(equal(16))
					expect(weather.humidity).to(equal(0.49))
					expect(weather.precipitation).to(equal(0))
					guard let wind = weather.wind else {
						expect(weather.wind).toNot(beNil()); return
					}
					expect(wind.heading).to(equal(299))
					expect(wind.speed).to(equal(13))
					expect(wind.gusting).to(equal(0))
				}
				.doOnError { expect($0).to(beNil()); done() }
				.doOnCompleted(done)
				.subscribe()
				.addDisposableTo(self.disposeBag)
		}
	}

}
