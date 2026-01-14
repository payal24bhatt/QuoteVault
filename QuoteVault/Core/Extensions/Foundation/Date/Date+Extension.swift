//
//  Date+Extension.swift
//

import Foundation

enum DateFormates : String {
    case MMM_d_yyyy = "MMM d, yyyy"
    case hh_mm_a = "hh:mm a"
    case twentyFourHoursTimeFormate = "HH:mm"
    case yyyy_MM_dd = "yyyy-MM-dd"
    case YYYY_MM_DD = "YYYY-MM-DD"
    case dd_MM_yyyy = "dd-MM-yyyy"
    case longTime = "h:mm a 'on' MMM d, yyyy"
    case serverDateAndTime = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    case dayOfWeek = "EEEE"
    case dd_MM_yyyy_withslash = "dd/MM/yyyy"
    case datewithTimeDash = "yyyy-MM-dd HH:mm:ss"
    case datewithTimeSlash = "dd/MM/yyyy HH:mm"
    case dateShowAppFromate = "dd MMM yyyy"
    case dd_MMM_Comma_YYYY = "dd MMM, yyyy"
    case MMMM_YYYY = "MMMM yyyy"
    case dd_MMMM = "dd MMMM"
    case dd_MMM = "dd MMM"
//    case MMMM_YYY = "MMMM yyyy"
   // yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ
}

extension Date {

    func toString(format: String) -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.system
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        return dateFormatter.string(from: self)
    }

    func localToGMT(format: String) -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(identifier:"GMT")

        return dateFormatter.string(from: self)
    }

    func isBefore(date:Date) -> Bool {
        if (self.compare(date) == .orderedAscending) { return true }
        return false
    }

    func isEqual(date:Date) -> Bool {
        if (self.compare(date) == .orderedSame) { return true }
        return false
    }

    func isEqualOrBefore(date:Date) -> Bool {
        if (self.isBefore(date: date) || self.isEqual(date: date)) { return true }
        return false
    }

    func isAfter(date:Date) -> Bool {
        if (self.compare(date) == .orderedDescending) { return true }
        return false
    }

    func isEqualOrAfter(date:Date) -> Bool {
        if (self.isAfter(date: date) || self.isEqual(date: date)) { return true }
        return false
    }

    func dateByAdd(days: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.day = days
        return Calendar.shared().date(byAdding: dateComponents, to: self)!
    }

    // To compare two date with same formate
    func compareTwoDates(startDate : String, endDate : String, formate : String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formate
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

//        if Localization.sharedInstance.getLanguage() == CLanguageSpanish { // For MultiLanguage
//            dateFormatter.locale = Locale(identifier: CLanguageSpanish)
//        } else {
//            dateFormatter.locale = Locale(identifier: CLanguageEnglish)
//        }
//
        guard let startDateTime = dateFormatter.date(from: startDate) else {
            return false
        }
        guard let endDateTime = dateFormatter.date(from: endDate) else {
            return false
        }
        return endDateTime > startDateTime
    }
}

// MARK: - Extension - Calendor Singleton
// MARK: -
extension Calendar {
    private static var sharedInstance: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = NSTimeZone.system
        return calendar
    }()
    static func shared() -> Calendar {
        return sharedInstance
    }
}

extension Date {

    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

// MARK: - Extension - DateFormatter Singleton -

extension DateFormatter {

    private static var sharedInstance: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.system
        return dateFormatter
    }()

    static func shared() -> DateFormatter {
        return sharedInstance
    }

    func string(fromDate: Date, dateFormat: String) -> String {
        self.dateFormat = dateFormat
        return self.string(from: fromDate)
    }

    func date(fromString: String, dateFormat: String) -> Date? {
        self.dateFormat = dateFormat
        return self.date(from: fromString)
    }

    func gmtToLocalString(fromString: String, dateFormat: String) -> String {

        let dateFormatter = DateFormatter()
        self.dateFormat = dateFormat
        self.timeZone = TimeZone(identifier:"GMT")

        let date = dateFormatter.date(from: fromString)
        self.timeZone = TimeZone.current
        self.dateFormat = dateFormat

        return self.string(from: date ?? Date())
    }

    func gmtToLocalDate(fromString: String, dateFormat: String) -> Date? {

        self.timeZone = TimeZone(identifier:"GMT")
        let date = self.date(fromString: fromString, dateFormat: dateFormat)
        self.timeZone = TimeZone.current
        self.dateFormat = dateFormat

        return date
    }

    // Conversion of 24 Hour time to 12 Hour time
    func timeConversion12(time24: String) -> String {
        self.dateFormat = "HH:mm"
        let date24 = self.date(from: time24) ?? Date()
        self.dateFormat = "hh:mm a"
        let time12 = self.string(from: date24)
        return time12
    }

    // Conversion of 24 Hour time to 12 Hour time
    func timeConversion24(time12: String) -> String {
        self.dateFormat = "hh:mm a"
        let date12 = self.date(from: time12) ?? Date()
        self.dateFormat = "HH:mm"
        let time24 = self.string(from: date12)
        return time24
    }
}

extension DateFormatter {

    func convertStringToString(convertDate: String) -> String {

        let date = self.date(fromString: convertDate, dateFormat: "yyyy-MM-dd")
        self.dateStyle = .full
        let convertedString = self.string(fromDate: date ?? Date(), dateFormat: "EEEE, dd MMM yyyy")
        return convertedString
    }

    func convertStringToStringddMMyyyyEEEE(convertDate: String) -> String {

        let date = self.date(fromString: convertDate, dateFormat: "yyyy-MM-dd")
        self.dateStyle = .full
        let convertedString = self.string(fromDate: date ?? Date(), dateFormat: "dd/MM/yyyy, EEEE")
        return convertedString
    }

    func convertStringToStringyyyyMMdd(convertDate: String) -> String {

        let date = self.date(fromString: convertDate, dateFormat: "dd/MM/yyyy, EEEE")
        self.dateStyle = .full
        let convertedString = self.string(fromDate: date ?? Date(), dateFormat: "yyyy-MM-dd")
        return convertedString
    }

    // To Get GMT Timestamp from Specific Date
    func timestampGMTFromDate(date: String?, formate: String?) -> Double? {
        self.dateFormat = formate
        self.timeZone = TimeZone(abbreviation: "GMT")
        var timeStamp = self.date(from: date!)?.timeIntervalSince1970
        timeStamp = Double(timeStamp!)
        return timeStamp
    }

    // To Get GMT Timestamp from current date.
    func currentGMTTimestampInMilliseconds() -> Double? {
        let format = "yyyy-MM-dd HH:mm:ss.SSSS'Z'"
        self.dateFormat = format
        self.timeZone = TimeZone(identifier: "GMT")
        let createDate = self.string(from: Date())
        let timestamp = self.timestampGMTFromDate(date: createDate, formate: format)
        return timestamp! * 1000
    }

    // To Get local Timestamp from specific date
    func timestampFromDate(date: String?, formate: String?) -> Double? {
        self.dateFormat = formate
        self.timeZone = TimeZone.current
        var timeStamp = self.date(from: date!)?.timeIntervalSince1970
        timeStamp = Double(timeStamp!)
        return timeStamp
    }

    // To Convert GMT timestamp to local timestamp
    func convertGMTMillisecondsTimestampToLocalTimestamp(timestamp: Double) -> Double? {
        let format = "yyyy-MM-dd HH:mm:ss.SSSS'Z'"
        self.dateFormat = format
        self.timeZone = TimeZone.current
        let dateStr = NSDate(timeIntervalSince1970:timestamp)
        let createDate = self.string(from: dateStr as Date)
        let gmtTimestamp = self.timestampFromDate(date: createDate, formate: format)
        return gmtTimestamp
    }

    // To Get date string from timestamp
    static func dateStringFrom(timestamp: Double, withFormate:String?) -> String {

        let date = Date(timeIntervalSince1970: timestamp)
         DateFormatter.shared().locale = .current
         return DateFormatter.shared().string(fromDate: date, dateFormat: withFormate!)
     }

    func setTimeAccordingTimeFormat(timestamp: Double?) -> String {

        let fromDate:Date = Date(timeIntervalSince1970: timestamp!)
        DateFormatter.shared().locale = .current
        DateFormatter.shared().timeZone = .current
        let formatter : String = DateFormatter.dateFormat(fromTemplate: "j", options:0, locale:DateFormatter.shared().locale)!

        // Containts a means Phone is set to 12 hours or Phone is set to 24 hours
        return formatter.contains("a") ? DateFormatter.shared().string(fromDate: fromDate, dateFormat: "hh:mm a") : DateFormatter.shared().string(fromDate: fromDate, dateFormat: "HH:mm")
    }
}

extension Date {
    func getTimeDifferenceInSecond(startDate: Date) -> Int? {
        let calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>([ .second])
        let dateComponents = calendar.dateComponents(unitFlags, from: startDate, to: self)
        return dateComponents.second
    }
}
