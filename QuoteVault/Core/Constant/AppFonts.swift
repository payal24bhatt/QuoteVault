//
//  ApplicationFonts.swift
//

import UIKit

enum FontName: String {
    case futuraBold = "Futura-Bold"
    case futuraMedium = "Futura-Medium"
    case futuraCondensedMedium = "Futura-CondensedMedium"
    case futuraCondensedExtraBold = "Futura-CondensedExtraBold"
    case futuraRegular = "Futura"
}

extension UIFont {
    
    class func custom(name: FontName = FontName.futuraRegular, size: CGFloat = 15.0) -> UIFont {
        if let font = UIFont(name: name.rawValue, size: autoDimension(size: size)) {
            return font
        }
        return UIFont.systemFont(ofSize: size)
    }
    
    static func autoDimension(size: CGFloat) -> CGFloat {
        return ((UIDevice.screenWidth * size) / 375.0)
    }
}
