//
//  Double+Extension.swift
//

import Foundation
import UIKit

extension Double {

    var toInt:Int? {
        return Int(self)
    }

    var toFloat:Float? {
        return Float(self)
    }

    var toString:String {
        return "\(self)"
    }

    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }

    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: self))!
    }
}
