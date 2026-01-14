//
//  CGFloat+Extension.swift
//

import Foundation
import UIKit

extension CGFloat {

    func roundedToPlace(_ places:Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return (self * divisor).rounded() / divisor
    }
}
