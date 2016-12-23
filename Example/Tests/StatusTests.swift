//
//  StatusTests.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/1/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

@testable import AirMap
import Nimble
import RxSwift

class StatusTests: TestCase {

	let disposeBag = DisposeBag()

	func testGetPointStatus() {
		
		let whiteHouseCoordinate = CoordinateFactory.whiteHouseCoordinate()
		let date = NSDate.dateFromISO8601String("2016-12-01T00:00:00.000Z")

		stub(.GET, Config.AirMapApi.statusUrl + "/point", with: "status_get_point_success.json") { request in
			let query = request.queryParams()
			expect(query["buffer"] as? String).to(equal(String(500)))
			expect(query["weather"] as? String).to(equal(String(false)))
			expect(query["datetime"] as? String).to(equal(date.ISO8601String()))
			expect(query["latitude"] as? String).to(equal(String(whiteHouseCoordinate.latitude)))
			expect(query["longitude"] as? String).to(equal(String(whiteHouseCoordinate.longitude)))
		}

		waitUntil { done in

			AirMap.rx_checkCoordinate(whiteHouseCoordinate, buffer: 500, weather: false, date: date)
				.doOnNext { status in
					expect(status.maxSafeDistance).to(equal(0))
					expect(status.advisories.count).to(equal(23))
					expect(status.advisoryColor).to(equal(AirMapStatus.StatusColor.Red))
				}
				.doOnError {
					expect($0).to(beNil()); done()
				}
				.doOnCompleted(done)
				.subscribe()
				.addDisposableTo(self.disposeBag)
		}
	}

	func testGetFlightPathStatus() {

		stub(.GET, Config.AirMapApi.statusUrl + "/path", with: "status_get_path_success.json") { request in
			let query = request.queryParams()
			expect(query["geometry"] as? String).to(equal("LINESTRING(-118.451 34.016,-118.4964 34.0099)"))
		}

		waitUntil { done in

			let path = [
				CoordinateFactory.ksmoCoordinate(),
				CoordinateFactory.santaMonicaPierCoordinate()
			]

			AirMap.rx_checkFlightPath(path, buffer: 100, takeOffPoint: path.first!)
				.doOnNext { status in
					expect(status.maxSafeDistance).to(equal(0))
					expect(status.advisories.count).to(equal(17))
					expect(status.advisoryColor).to(equal(AirMapStatus.StatusColor.Red))
				}
				.doOnError { expect($0).to(beNil()); done() }
				.doOnCompleted(done)
				.subscribe()
				.addDisposableTo(self.disposeBag)
		}
	}

	func testGetFlightPolygonStatus() {

		let polygon = CoordinateFactory.marinaDelReyMarinaPolygonCoordinates()
		
		stub(.GET, Config.AirMapApi.statusUrl + "/polygon", with: "status_get_polygon_success.json") { request in
			let query = request.queryParams()
			let coordinates = polygon + [polygon.first!]
			let coordinatesString = coordinates.map { "\($0.longitude) \($0.latitude)" }.joinWithSeparator(",")
			let wkt = "POLYGON(\(coordinatesString))"
			expect(query["geometry"] as? String).to(equal(wkt))
			expect(query["buffer"]).to(beNil())
			expect(query["weather"] as? String).to(equal(String(false)))
			let latitude = Double(query["latitude"] as? String ?? "")
			let longitude = Double(query["longitude"] as? String ?? "")
			expect(latitude).to(beCloseTo(polygon.first!.latitude))
			expect(longitude).to(beCloseTo(polygon.first!.longitude))
		}

		waitUntil { done in

			AirMap.rx_checkPolygon(polygon, takeOffPoint: polygon.first!)
				.doOnNext { status in
					expect(status.maxSafeDistance).to(equal(0))
					expect(status.advisories.count).to(equal(15))
					expect(status.advisoryColor).to(equal(AirMapStatus.StatusColor.Yellow))
				}
				.doOnError { expect($0).to(beNil()); done() }
				.doOnCompleted(done)
				.subscribe()
				.addDisposableTo(self.disposeBag)
		}
	}

	func testWeatherStatus() {

		stub(.GET, Config.AirMapApi.statusUrl + "/point", with: "status_weather_success.json") { request in
			let query = request.queryParams()
			expect(query["weather"] as? String).to(equal(String(true)))
		}

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
