//
//  Date+AirMap.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 5/26/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

public extension Date {
	
	@nonobjc static let shortDateFormatter: DateFormatter = {
		$0.dateStyle = .short
		$0.timeStyle = .short
		$0.doesRelativeDateFormatting = true
		return $0
	}(DateFormatter())
	
	public func ISO8601String() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
		return dateFormatter.string(from: self)
	}
	
	public static func dateFromISO8601String(_ string: String) -> Date {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		dateFormatter.timeZone = TimeZone.autoupdatingCurrent
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
		return dateFormatter.date(from: string)!
	}
	
	func greaterThanDate(_ date: Date) -> Bool {
		return (self.compare(date) == ComparisonResult.orderedDescending)
	}
	
	func lessThanDate(_ date: Date) -> Bool {
		return (self.compare(date) == ComparisonResult.orderedAscending)
	}
	
	func isInFuture() -> Bool {
		return greaterThanDate(Date())
	}
	
	func isInPast() -> Bool {
		return lessThanDate(Date())
	}
	
	func equalToDate(_ date: Date) -> Bool {
		return (self.compare(date) == ComparisonResult.orderedSame)
	}
	
	func isToday() -> Bool {
		let comp1 = Date.components(self)
		let comp2 = Date.components(Date())
		return ((comp1!.year == comp2!.year) && (comp1!.month == comp2!.month) && (comp1!.day == comp2!.day))
	}
	
	func dateBySubtractingTimeInterval(_ interval: TimeInterval) -> Date {
		return Date(timeInterval: -interval, since: Date())
	}
	
	func oneHourEarlier() -> Date {
		return dateBySubtractingTimeInterval(60*60)
	}
	
	func minutesEarlier(_ minutes: Int) -> Date {
		return dateBySubtractingTimeInterval(60*Double(minutes))
	}
	
	func minutesLater(_ minutes: Int) -> Date {
		return addingTimeInterval(60*Double(minutes))
	}
	
	func oneHourLater() -> Date {
		return addingTimeInterval(60*60)
	}
	
	func dateByAddingDays(_ days: Int) -> Date {
		return (Calendar.current as NSCalendar).date(byAdding: .day, value: days, to: self, options: NSCalendar.Options())!
	}
	
	func startOfDay() -> Date {
		return Calendar.current.startOfDay(for: self)
	}
	
	func endOfDay() -> Date {
		var components = DateComponents()
		components.day = 1
		components.second = -1
		return (Calendar.current as NSCalendar).date(
			byAdding: components, to: startOfDay(),
			options: NSCalendar.Options()
			)!
	}
	
	func nearest15Minutes() -> Date {
		var comps = Date.components(self)
		let minutes = (((((comps?.minute)! - 8) / 15) * 15) + 15)
		comps?.minute = minutes
		comps?.second = 0
		return Calendar.current.date(from: comps!)!
	}
	
	func shortDateString() -> String {
		return Date.shortDateFormatter.string(from: self)
	}
	
	func dateComponents() -> (hours: Int, minutes: Int, seconds: Int) {
		let calendar = Calendar.current
		let comp = (calendar as NSCalendar).components([.hour, .minute, .second], from: self)
		let hrs = comp.hour
		let min = comp.minute
		let sec = comp.second
		
		return (hrs!, min!, sec!)
	}
	
	fileprivate static func components(_ fromDate: Date) -> DateComponents! {
		return (Calendar.current as NSCalendar).components(Date.componentFlags(), from: fromDate)
	}
	
	fileprivate func addComponents(_ components: DateComponents) -> Date {
		let cal = Calendar.current
		return (cal as NSCalendar).date(byAdding: components, to: self, options: NSCalendar.Options())!
	}
	
	fileprivate static func componentFlags() -> NSCalendar.Unit {
		return [NSCalendar.Unit.year,
		        NSCalendar.Unit.month,
		        NSCalendar.Unit.day,
		        NSCalendar.Unit.weekOfYear,
		        NSCalendar.Unit.hour,
		        NSCalendar.Unit.minute,
		        NSCalendar.Unit.second,
		        NSCalendar.Unit.weekday,
		        NSCalendar.Unit.weekdayOrdinal,
		        NSCalendar.Unit.weekOfYear]
	}
	
}

extension TimeInterval {
	
	var milliseconds: UInt64 {
		return UInt64(self * 1000)
	}
}
