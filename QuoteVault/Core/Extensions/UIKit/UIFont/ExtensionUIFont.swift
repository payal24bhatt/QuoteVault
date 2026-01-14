//
//  ExtensionUIFont.swift
//

import Foundation
import UIKit

extension UIFont {

    func setUpAppropriateFont() -> UIFont? {

        if UIDevice.isIPhone5 {
            return UIFont(name: self.fontName, size: self.pointSize - 3.0)
        } else if UIDevice.isIPhone6Plus || UIDevice.isIPhoneXR {
            return UIFont(name: self.fontName, size: self.pointSize + 2.0)
        } else {
            return UIFont(name: self.fontName, size: self.pointSize)
        }
    }

    func autoDimentionFont() -> UIFont {

        let dimentedSize = ((UIDevice.screenWidth * pointSize) / 375.0)
        return (UIFont(name: fontName, size: dimentedSize) ?? UIFont.systemFont(ofSize: dimentedSize))
    }
}
