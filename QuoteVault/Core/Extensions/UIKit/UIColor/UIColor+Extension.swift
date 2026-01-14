//
//  UIColor+Extension.swift
//

import Foundation
import UIKit

extension UIColor {

    convenience init(hexString: String) {

        var _hexString: String = (hexString as NSString).trimmingCharacters(in: .whitespacesAndNewlines)
        if _hexString.hasPrefix("#") {
            _hexString = String(_hexString.dropFirst())
        }
        let scanner = Scanner(string: _hexString)

        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let mask = 0x000000FF
        let r = Int(rgbValue >> 16) & mask
        let g = Int(rgbValue >> 8) & mask
        let b = Int(rgbValue) & mask

        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}

extension UIColor {
    var hexString: String? {
        if let components = self.cgColor.components {
            let r = components[0]
            let g = components[1]
            let b = components[2]
            return String(format: "%02X%02X%02X", (Int)(r * 255), (Int)(g * 255), (Int)(b * 255))
        }
        return nil
    }
}
