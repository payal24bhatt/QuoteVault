//
//  UIResponder+Extension.swift
//

import Foundation
import UIKit

extension UIResponder {
    var className: String {
        return String(describing: type(of: self)).components(separatedBy: ".").last ?? ""
    }
}
