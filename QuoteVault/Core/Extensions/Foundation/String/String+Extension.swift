//
//  String+Extension.swift
//

import Foundation
import UIKit

// MARK: - Extension of String For Converting it TO Int AND URL. -

extension String {

    /// A Computed Property (only getter) of Int For getting the Int? value from String.
    /// This Computed Property (only getter) returns Int? , it means this Computed Property (only getter) return nil value also , while using this Computed Property (only getter) please use if let.
    /// If you are not using if let and if this Computed Property (only getter) returns nil and when you are trying to unwrapped this value("Int!") then application will crash.
    var toInt: Int? {
        return Int(self)
    }
    var toDouble: Double? {
        return Double(self)
    }
    var toFloat: Float? {
        return Float(self)
    }
    /// A Computed Property (only getter) of URL For getting the URL from String.
    /// This Computed Property (only getter) returns URL? , it means this Computed Property (only getter) return nil value also , while using this Computed Property (only getter) please use if let.
    /// If you are not using if let and if this Computed Property (only getter) returns nil and when you are trying to unwrapped this value("URL!") then application will crash.
    var toURL: URL? {
        return URL(string: self)
    }

    func toDate(fromFormat : DateFormates = .serverDateAndTime) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = fromFormat.rawValue
        return dateFormatter.date(from: self) ?? Date()
    }
    
    func toFormattedDate(fromFormat: DateFormates = .serverDateAndTime,
                             toFormat: DateFormates = .dd_MMM) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = fromFormat.rawValue
        
        if let date = dateFormatter.date(from: self) {
            let outputFormatter = DateFormatter()
            outputFormatter.locale = Locale(identifier: "en_US_POSIX")
            outputFormatter.dateFormat = toFormat.rawValue
            return outputFormatter.string(from: date)
        }
        return self
    }
    func daysBetweenDates(fromFormat: DateFormates = .serverDateAndTime, to otherDateString: String, otherFormat: DateFormates = .serverDateAndTime) -> Int {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            
            // Parse first date
            formatter.dateFormat = fromFormat.rawValue
            guard let firstDate = formatter.date(from: self) else { return 0 }
            
            // Parse second date
            formatter.dateFormat = otherFormat.rawValue
            guard let secondDate = formatter.date(from: otherDateString) else { return 0 }
            
            // Normalize to ignore time differences
            let calendar = Calendar.current
            let startOfFirst = calendar.startOfDay(for: firstDate)
            let startOfSecond = calendar.startOfDay(for: secondDate)
            
            let components = calendar.dateComponents([.day], from: startOfFirst, to: startOfSecond)
            return components.day ?? 0
        }
}

extension String {

    func removingWhitespaceAndNewlines() -> String {
        return self.removingCharactersInSet(CharacterSet.whitespacesAndNewlines)
    }

    func removingCharactersInSet(_ set: CharacterSet) -> String {
        let stringParts = self.components(separatedBy: set)
        let notEmptyStringParts = stringParts.filter { text in
            text.isEmpty == false
        }
        let result = notEmptyStringParts.joined(separator: "")
        return result
    }

    var trim: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isBlank: Bool {
        return self.trim.isEmpty
    }

    var isAlphanumeric: Bool {
        return !isBlank && rangeOfCharacter(from: .alphanumerics) != nil
    }
    var digits: String {
          return components(separatedBy: CharacterSet.decimalDigits.inverted)
              .joined()
    }
    var isValidEmail: Bool {

        let emailRegEx = "^[A-Z0-9a-z]+(?:[._%+-]?[A-Za-z0-9]+)+@[A-Za-z0-9-]+(\\.[A-Za-z]{2,4})+$"

        let predicate = NSPredicate(
            format:"SELF MATCHES %@",
            emailRegEx
        )

        return predicate.evaluate(with:self)
    }

    var isValidMobileNo: Bool {
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{4,15}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: self)
    }

    var isValidPassword: Bool {
//        let passwordRegex = "^(?=.*[a-z])(?=.*[@$!%*#?&])(?=.*[0-9])[0-9a-zA-Z@$!%*#?&]{8,}"
        let passwordRegex = "[0-9a-zA-Z-@$!%*#?&]{6,}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
        return predicate.evaluate(with:self)
    }

    var isValidZip: Bool {
        let passwordRegex = "[0-9a-zA-Z]{4,}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
        return predicate.evaluate(with:self)
    }

    var isValidURL: Bool {
        let urlRegEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: self)
    }

    var isAlphabetic: Bool {
        let urlRegEx = "[a-zA-Z][a-zA-Z ]+[a-zA-Z]$"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: self)
    }
}

extension String {

    func getWidth(font: UIFont) -> CGFloat {
        let bounds = (self as NSString).size(withAttributes: [.font:font])
        return bounds.width
    }

    func getHeight(font: UIFont) -> CGFloat {
        let bounds = (self as NSString).size(withAttributes: [.font:font])
        return bounds.height
    }
}

extension String {
    func htmlAttributed(font: FontName, size: CGFloat, color: UIColor) -> NSAttributedString? {
        do {
            let trimmedString = self.trimmingCharacters(in: .whitespacesAndNewlines)
            let lines = trimmedString.components(separatedBy: .newlines)
            let nonEmptyLines = lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            let cleanedString = nonEmptyLines.joined(separator: "<br>").trimmingCharacters(in: .whitespacesAndNewlines)

            let hex = "FFFFFF"

            let htmlCSSString = """
            <html>
            <head>
            <style>
            body {
                margin: 0;
                padding: 0;
                font-size: \(size)pt;
                color: #\(hex);
                font-family: \(font.rawValue);
                line-height: \(size)pt; /* Match exact point size to minimize extra space */
            }
            p, ul, ol, li {
                margin: 0;
                padding: 0;
            }
            ul, ol {
                list-style-type: none;
            }
            a {
                color: #\(hex);
            }
            </style>
            </head>
            <body>\(cleanedString)</body>
            </html>
            """


            guard let data = htmlCSSString.data(using: .utf8) else { return nil }

            return try NSAttributedString(data: data,
                                          options: [
                                            .documentType: NSAttributedString.DocumentType.html,
                                            .characterEncoding: String.Encoding.utf8.rawValue
                                          ],
                                          documentAttributes: nil)
        } catch {
            print("HTML parse error: \(error)")
            return nil
        }
    }
}

extension NSMutableAttributedString {
 var fontSize:CGFloat { return 18 }
    var normalFont:UIFont { return UIFont.custom(name: .futuraRegular, size: fontSize) }

    func bold(_ value:String , fontSize : CGFloat,  fontColor : UIColor = .black) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font : UIFont.custom(name: .futuraMedium, size: fontSize) ,// boldFont,
            .foregroundColor : fontColor
        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }

    func normal(_ value:String, fontSize : CGFloat , fontColor : UIColor = .black) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font : UIFont.custom(name: .futuraRegular, size: fontSize),
            .foregroundColor : fontColor
        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func normal(_ value:String, fontColor : UIColor = .black, font: UIFont? = nil) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font : font ?? normalFont,
            .foregroundColor : fontColor
        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }

    func orangeHighlight(_ value:String) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor : UIColor.white,
            .backgroundColor : UIColor.orange
        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }

    func blackHighlight(_ value:String) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor : UIColor.white,
            .backgroundColor : UIColor.black

        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func underlined(_ value: String, font: UIFont? = nil) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font ?? normalFont,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.black
        ]

        return NSMutableAttributedString(string: value, attributes: attributes)
    }

    func setColorForText(_ textToFind: String, with colour: UIColor) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            addAttribute(NSAttributedString.Key.foregroundColor, value: colour, range: range)
        }
    }

    func setFontForText(_ textToFind: String, with font: UIFont) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            addAttribute(NSAttributedString.Key.font, value: font, range: range)
        }
    }

    func setAlignment(text:String, alignment:NSTextAlignment) {
        let range = self.mutableString.range(of: text, options: .caseInsensitive)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment

        addAttributes([NSAttributedString.Key.paragraphStyle:paragraphStyle], range: range)
    }
}

extension String {
    func attributedStringWithColor(_ strings: [String], color: UIColor, characterSpacing: UInt? = nil, image: UIImage? = nil, font: UIFont? = nil) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        for string in strings {
            let range = (self as NSString).range(of: string)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
            if let font {
                attributedString.addAttribute(NSAttributedString.Key.font, value: font, range: range)
            }
        }
        
        guard let characterSpacing = characterSpacing else {return attributedString}
        
        attributedString.addAttribute(NSAttributedString.Key.kern, value: characterSpacing, range: NSRange(location: 0, length: attributedString.length))
        
        return attributedString
    }
}

extension String {
    /*
     func attributedStringWithAttributes(
     _ attributes: [(string: String, color: UIColor, font: UIFont?)],
     characterSpacing: UInt? = nil,
     image: UIImage? = nil,
     imageSize: CGSize = CGSize(width: 12, height: 12),
     spaceBeforeImage: CGFloat = 6 // Customize spacing
     ) -> NSAttributedString {
     
     let attributedString = NSMutableAttributedString(string: self)
     
     // Apply color and font attributes
     for attribute in attributes {
     let range = (self as NSString).range(of: attribute.string)
     if range.location != NSNotFound {
     attributedString.addAttribute(.foregroundColor, value: attribute.color, range: range)
     if let font = attribute.font {
     attributedString.addAttribute(.font, value: font, range: range)
     }
     }
     }
     
     // Apply character spacing if provided
     if let characterSpacing = characterSpacing {
     attributedString.addAttribute(.kern, value: characterSpacing, range: NSRange(location: 0, length: attributedString.length))
     }
     
     // Append image with space if provided
     if let image = image {
     let attachment = NSTextAttachment()
     attachment.image = image
     attachment.bounds = CGRect(x: 0, y: -2, width: imageSize.width, height: imageSize.height) // Adjust positioning
     
     let spaceString = NSAttributedString(string: String(repeating: "\u{00A0}", count: Int(spaceBeforeImage / 2))) // Adds space before the image
     let imageAttributedString = NSAttributedString(attachment: attachment)
     
     attributedString.append(spaceString) // Space before image
     attributedString.append(imageAttributedString)
     }
     
     return attributedString
     }
     */
    func attributedStringWithAttributes(
        _ attributes: [(string: String, color: UIColor, font: UIFont?)],
        characterSpacing: UInt? = nil,
        image: UIImage? = nil,
        imageSize: CGSize = CGSize(width: 12, height: 12),
        spaceBeforeImage: CGFloat = 6 // Customize spacing
    ) -> NSAttributedString {
        
        let attributedString = NSMutableAttributedString(string: self)
        let lowercasedSelf = self.lowercased() // for case-insensitive search
        
        // Apply color and font attributes
        for attribute in attributes {
            let searchString = attribute.string.lowercased()
            var searchRange = lowercasedSelf.startIndex..<lowercasedSelf.endIndex
            
            // Loop to find all case-insensitive matches
            while let range = lowercasedSelf.range(of: searchString, options: [], range: searchRange) {
                let nsRange = NSRange(range, in: self)
                
                attributedString.addAttribute(.foregroundColor, value: attribute.color, range: nsRange)
                if let font = attribute.font {
                    attributedString.addAttribute(.font, value: font, range: nsRange)
                }
                
                // Move past this match to find next
                searchRange = range.upperBound..<lowercasedSelf.endIndex
            }
        }
        
        // Apply character spacing if provided
        if let characterSpacing = characterSpacing {
            attributedString.addAttribute(.kern, value: characterSpacing, range: NSRange(location: 0, length: attributedString.length))
        }
        
        // Append image with space if provided
        if let image = image {
            let attachment = NSTextAttachment()
            attachment.image = image
            attachment.bounds = CGRect(x: 0, y: -2, width: imageSize.width, height: imageSize.height)
            
            let spaceString = NSAttributedString(string: String(repeating: "\u{00A0}", count: Int(spaceBeforeImage / 2)))
            let imageAttributedString = NSAttributedString(attachment: attachment)
            
            attributedString.append(spaceString)
            attributedString.append(imageAttributedString)
        }
        
        return attributedString
    }
    
}




extension String {
    func underlineText(arrStrings:[String]) -> NSAttributedString {
        
        let attributedString = NSMutableAttributedString(string: self)
        for text in arrStrings {
            if let range = self.range(of: text) {
                attributedString.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSRange(range, in: self))
            }
        }
        return attributedString
    }
    
    func setColorForText(_ textToFind: [String], with colour: UIColor) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        
        for text in textToFind {
            if let range = self.range(of: text) {
                attributedString.addAttribute(
                    NSAttributedString.Key.foregroundColor,
                    value: colour,
                    range: NSRange(range, in: self))
            }
        }
        return attributedString
    }

    func setAttributesForTextWithFont(_ textToFind: [String], color: UIColor, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        
        for text in textToFind {
            if let range = self.range(of: text) {
                let nsRange = NSRange(range, in: self)
                attributedString.addAttributes([
                    .foregroundColor: color,
                    .font: font
                ], range: nsRange)
            }
        }
        return attributedString
    }

    
    func setColorWithUnderlineForText(_ textToFind: [String], with colour: UIColor, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        
        for text in textToFind {
            if let range = self.range(of: text) {
                let nsRange = NSRange(range, in: self)
                attributedString.addAttributes([
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: colour,
                    .font: font // Apply the font only to the specific text
                ], range: nsRange)
            }
        }
        return attributedString
    }


    
    func appendingPathComponent(fileName: String, separator: String? = nil) -> String {
        if let separator {
            return "\(self)\(separator)\(fileName)"
        }
        return "\(self)\(fileName)"
    }
    
    /// jsonObjectArray is used to convert json string to json array object
    /// - Returns: [[String: Any?]] optional
    func jsonObjectArray() -> [[String: Any?]]? {
        guard let data = self.data(using: .utf8) else { return nil }
        
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [[String: Any?]] {
                return jsonArray
            }
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
}
