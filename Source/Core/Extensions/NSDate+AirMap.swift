//
//  NSDate+AirMap.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 5/26/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//


public extension NSDate {
	
	@nonobjc static let shortDateFormatter: NSDateFormatter = {
		$0.dateStyle = .ShortStyle
		$0.timeStyle = .ShortStyle
		$0.doesRelativeDateFormatting = true
		return $0
	}(NSDateFormatter())
	
	public func ISO8601String() -> String {
		let dateFormatter = NSDateFormatter()
		dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
		dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
		return dateFormatter.stringFromDate(self)
	}
	
	public class func dateFromISO8601String(string: String) -> NSDate {
		let dateFormatter = NSDateFormatter()
		dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
		dateFormatter.timeZone = NSTimeZone.localTimeZone()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
		return dateFormatter.dateFromString(string)!
	}
	
	func greaterThanDate(date: NSDate) -> Bool {
		return (self.compare(date) == NSComparisonResult.OrderedDescending)
	}
	
	func lessThanDate(date: NSDate) -> Bool {
		return (self.compare(date) == NSComparisonResult.OrderedAscending)
	}
	
	func isInFuture() -> Bool {
		return greaterThanDate(NSDate())
	}
	
	func isInPast() -> Bool {
		return lessThanDate(NSDate())
	}
	
	func equalToDate(date: NSDate) -> Bool {
		return (self.compare(date) == NSComparisonResult.OrderedSame)
	}
	
	func isToday() -> Bool {
		let comp1 = NSDate.components(fromDate: self)
		let comp2 = NSDate.components(fromDate: NSDate())
		return ((comp1.year == comp2.year) && (comp1.month == comp2.month) && (comp1.day == comp2.day))
	}
	
	func dateBySubtractingTimeInterval(interval: NSTimeInterval) -> NSDate {
		return NSDate(timeInterval: -interval, sinceDate: NSDate())
	}
	
	func oneHourEarlier() -> NSDate {
		return dateBySubtractingTimeInterval(60*60)
	}
	
	func minutesEarlier(minutes: Int) -> NSDate {
		return dateBySubtractingTimeInterval(60*Double(minutes))
	}
	
	func minutesLater(minutes: Int) -> NSDate {
		return dateByAddingTimeInterval(60*Double(minutes))
	}
	
	func oneHourLater() -> NSDate {
		return dateByAddingTimeInterval(60*60)
	}
	
	func dateByAddingDays(days: Int) -> NSDate {
		return NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: days, toDate: self, options: NSCalendarOptions())!
	}
	
	func startOfDay() -> NSDate {
		return NSCalendar.currentCalendar().startOfDayForDate(self)
	}
	
	func endOfDay() -> NSDate {
		let components = NSDateComponents()
		components.day = 1
		components.second = -1
		return NSCalendar.currentCalendar().dateByAddingComponents(
			components, toDate: startOfDay(),
			options: NSCalendarOptions()
			)!
	}
	
	func nearest15Minutes() -> NSDate {
		let comps = NSDate.components(fromDate: self)
		comps.minute = ((((comps.minute - 8) / 15) * 15) + 15)
		comps.second = 0
		return NSCalendar.currentCalendar().dateFromComponents(comps)!
	}
	
	func shortDateString() -> String {
		return NSDate.shortDateFormatter.stringFromDate(self)
	}
	
	func dateComponents() -> (hours: Int, minutes: Int, seconds: Int) {
		let calendar = NSCalendar.currentCalendar()
		let comp = calendar.components([.Hour, .Minute, .Second], fromDate: self)
		let hrs = comp.hour
		let min = comp.minute
		let sec = comp.second
		
		return (hrs, min, sec)
	}
	
	private class func components(fromDate fromDate: NSDate) -> NSDateComponents! {
		return NSCalendar.currentCalendar().components(NSDate.componentFlags(), fromDate: fromDate)
	}
	
	private func addComponents(components: NSDateComponents) -> NSDate {
		let cal = NSCalendar.currentCalendar()
		return cal.dateByAddingComponents(components, toDate: self, options: NSCalendarOptions())!
	}
	
	private class func componentFlags() -> NSCalendarUnit {
		return [NSCalendarUnit.Year,
		        NSCalendarUnit.Month,
		        NSCalendarUnit.Day,
		        NSCalendarUnit.WeekOfYear,
		        NSCalendarUnit.Hour,
		        NSCalendarUnit.Minute,
		        NSCalendarUnit.Second,
		        NSCalendarUnit.Weekday,
		        NSCalendarUnit.WeekdayOrdinal,
		        NSCalendarUnit.WeekOfYear]
	}
	
}
