////
////  StatusTests.swift
////  AirMapSDK
////
////  Created by Adolfo Martinelli on 7/1/16.
////  Copyright © 2016 AirMap, Inc. All rights reserved.
////
//
//@testable import AirMap
//import Nimble
//import RxSwift
//
//class StatusTests: TestCase {
//
//	func testGetPointStatus() {
//		
//		let whiteHouseCoordinate = CoordinateFactory.whiteHouseCoordinate()
//		let date = Date.dateFromISO8601String("2016-12-01T00:00:00.000Z")
//
//		stub(.get, Config.AirMapApi.statusUrl + "/point", with: "status_get_point_success.json") { request in
//			let query = request.queryParams()
//			expect(query["buffer"] as? String).to(equal(String(500)))
//			expect(query["weather"] as? String).to(equal(String(false)))
//			expect(query["datetime"] as? String).to(equal(date.ISO8601String()))
//			expect(query["latitude"] as? String).to(equal(String(whiteHouseCoordinate.latitude)))
//			expect(query["longitude"] as? String).to(equal(String(whiteHouseCoordinate.longitude)))
//		}
//
//		waitUntil { done in
//
//			AirMap.rx.checkCoordinate(coordinate: whiteHouseCoordinate, buffer: 500, weather: false, date: date)
//				.subscribe(
//					onNext: { status in
//						expect(status.maxSafeDistance).to(equal(0))
//						expect(status.advisories.count).to(equal(23))
//						expect(status.advisoryColor).to(equal(AirMapStatus.StatusColor.red)) },
//					onError: {
//						expect($0).to(beNil()); done() },
//					onCompleted: done
//				)
//				.disposed(by: self.disposeBag)
//		}
//	}
//
//	func testGetFlightPathStatus() {
//
//		stub(.get, Config.AirMapApi.statusUrl + "/path", with: "status_get_path_success.json") { request in
//			let query = request.queryParams()
//			expect(query["geometry"] as? String).to(equal("LINESTRING(-118.451 34.016,-118.4964 34.0099)"))
//		}
//
//		waitUntil { done in
//
//			let path = [
//				CoordinateFactory.ksmoCoordinate(),
//				CoordinateFactory.santaMonicaPierCoordinate()
//			]
//
//			AirMap.rx.checkFlightPath(path: path, buffer: 100, takeOffPoint: path.first!)
//				.subscribe(
//					onNext: { status in
//						expect(status.maxSafeDistance).to(equal(0))
//						expect(status.advisories.count).to(equal(17))
//						expect(status.advisoryColor).to(equal(AirMapStatus.StatusColor.red)) },
//					onError: { expect($0).to(beNil()); done() },
//					onCompleted: done
//				)
//				.disposed(by: self.disposeBag)
//		}
//	}
//
//	func testGetFlightPolygonStatus() {
//
//		let polygon = CoordinateFactory.marinaDelReyMarinaPolygonCoordinates()
//		
//		stub(.get, Config.AirMapApi.statusUrl + "/polygon", with: "status_get_polygon_success.json") { request in
//			let query = request.queryParams()
//			let coordinates = polygon + [polygon.first!]
//			let coordinatesString = coordinates.map { "\($0.longitude) \($0.latitude)" }.joined(separator: ",")
//			let wkt = "POLYGON(\(coordinatesString))"
//			expect(query["geometry"] as? String).to(equal(wkt))
//			expect(query["buffer"]).to(beNil())
//			expect(query["weather"] as? String).to(equal(String(false)))
//			let latitude = Double(query["latitude"] as? String ?? "")
//			let longitude = Double(query["longitude"] as? String ?? "")
//			expect(latitude).to(beCloseTo(polygon.first!.latitude))
//			expect(longitude).to(beCloseTo(polygon.first!.longitude))
//		}
//
//		waitUntil { done in
//
//			AirMap.rx.checkPolygon(geometry: polygon, takeOffPoint: polygon.first!)
//				.subscribe(
//					onNext: { status in
//						expect(status.maxSafeDistance).to(equal(0))
//						expect(status.advisories.count).to(equal(15))
//						expect(status.advisoryColor).to(equal(AirMapStatus.StatusColor.yellow)) },
//					onError: { expect($0).to(beNil()); done() },
//					onCompleted: done
//				)
//				.disposed(by: self.disposeBag)
//		}
//	}
//
//	func testWeatherStatus() {
//
//		stub(.get, Config.AirMapApi.statusUrl + "/point", with: "status_weather_success.json") { request in
//			let query = request.queryParams()
//			expect(query["weather"] as? String).to(equal(String(true)))
//		}
//
//		waitUntil { done in
//
//			let whiteHouseCoordinate = CoordinateFactory.whiteHouseCoordinate()
//
//			AirMap.rx.checkCoordinate(coordinate: whiteHouseCoordinate, buffer: 500, weather: true)
//				.subscribe(
//					onNext: { status in
//						guard let weather = status.weather else {
//							expect(status.weather).toNot(beNil()); return
//						}
//						expect(weather.temperature).to(equal(23))
//						expect(weather.condition).to(equal("Mostly Sunny"))
//						expect(weather.visibility).to(equal(16))
//						expect(weather.humidity).to(equal(0.49))
//						expect(weather.precipitation).to(equal(0))
//						guard let wind = weather.wind else {
//							expect(weather.wind).toNot(beNil()); return
//						}
//						expect(wind.heading).to(equal(299))
//						expect(wind.speed).to(equal(13))
//						expect(wind.gusting).to(equal(0)) },
//					onError: { expect($0).to(beNil()); done() },
//					onCompleted: done
//				)
//				.disposed(by: self.disposeBag)
//		}
//	}
//
//}
