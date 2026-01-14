//
//  UIStoryboard+Extension.swift
//

import Foundation
import UIKit

extension UIStoryboard {
    func instanceFrom<T: UIViewController>(controller: T.Type) -> T? {
        let indentifier = "\((controller as UIViewController.Type))"
        return self.instantiateViewController(withIdentifier: indentifier) as? T
    }
}
