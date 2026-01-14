//
//  Extension+UILabel.swift
//  RECCE
//
//  Created by Arjav Prajapati on 12/03/25.
//
import UIKit
import ObjectiveC

extension UILabel {
    private struct AssociatedKeys1 {
        static var isAutoCapitalized = "isAutoCapitalized".hashValue
    }
    
    @IBInspectable
    var isAutoCapitalized: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys1.isAutoCapitalized) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys1.isAutoCapitalized, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateCapitalization()
        }
    }
    
    private func updateCapitalization() {
        guard let text = self.text else { return }
        self.text = isAutoCapitalized ? text.uppercased() : text
    }
}


extension UILabel {
    @IBInspectable var fontName: String {
        get {
            return self.font.fontName
        }
        set {
            self.font = UIFont.systemFont(ofSize: 14)
        }
    }
    
    @IBInspectable var fontSize: CGFloat {
        get {
            return self.font.pointSize
        }
        set {
            self.font = self.font.withSize(newValue)
        }
    }
}
