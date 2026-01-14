//
//  HTString+String.swift
//  HearingTool
//
//  Created by Vivek Bhoraniya on 31/12/18.
//  Copyright © 2018 Brainvire. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    /// this function used to add country code as a prefix
    /// - Parameter countryCode: CountryCode as String
    /// - Returns: Country code as a prefix String
    func addCountryCode(to countryCode: String? = Constants.countryCode) -> String {
        guard let code = countryCode else { return self }
        return "\(code) \(self)"
    }

    var formattedTime:String {
        let unixTimestamp = Double(self)
        let date = Date(timeIntervalSince1970: unixTimestamp!)

        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "hh:mm a"
        // UnComment below to get only time
        //  dayTimePeriodFormatter.dateFormat = "hh:mm a"

        let dateString = dayTimePeriodFormatter.string(from: date as Date)

        return dateString
    }

    var trimmed: String {

        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    var length: Int {

        return self.count
    }

    var trimmedLength: Int {

        return self.trimmed.length
    }

    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.width)
    }

    var html2AttributedString: NSAttributedString? {
           guard let data = self.data(using: .utf8) else { return nil }

           let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
               .documentType: NSAttributedString.DocumentType.html,
               .characterEncoding: String.Encoding.utf8.rawValue
           ]

        let defaultFont = UIFont.custom(name: .futuraRegular, size: 14)
           let defaultAttributes: [NSAttributedString.Key: Any] = [
               .font: defaultFont,
               .foregroundColor: UIColor.black
           ]

           if let attrStr = try? NSMutableAttributedString(data: data, options: options, documentAttributes: nil) {
               attrStr.addAttributes(defaultAttributes, range: NSRange(location: 0, length: attrStr.length))
               return attrStr
           }

           return nil
       }

    var html2Privacy: NSMutableAttributedString? {
        do {

            let attributedString: NSMutableAttributedString = try NSMutableAttributedString(data: Data(utf8),
                                                                                            options: [
                                                                                                .documentType: NSAttributedString.DocumentType.html,
                                                                                                .characterEncoding: String.Encoding.utf8.rawValue],
                                                                                            documentAttributes: nil)

            return attributedString
        } catch {
            print("error: ", error)
            return nil
        }

    }

    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}
