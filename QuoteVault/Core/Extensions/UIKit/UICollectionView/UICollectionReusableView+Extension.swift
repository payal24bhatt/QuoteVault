//
//  UICollectionReusableView+Extension.swift
//

import Foundation
import UIKit

extension UICollectionReusableView {
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    static var identifier: String {
        return String(describing: self)
    }
}
