//
//  UIButton+Extension.swift
//

import Foundation
import UIKit

typealias GenericTouchUpInsideHandler<T> = ((T) -> Void)

// MARK: - Extension of UIButton For TouchUpInside Handler. -

extension UIButton {

    /// This Private Structure is used to create all AssociatedObjectKey which will be used within this extension.
    private struct AssociatedObjectKey {
        static var genericTouchUpInsideHandler = "genericTouchUpInsideHandler"
    }

    /// This method is used for UIButton's touchUpInside Handler
    /// - Parameter genericTouchUpInsideHandler: genericTouchUpInsideHandler will give you object of UIButton.
    func touchUpInside(genericTouchUpInsideHandler: @escaping GenericTouchUpInsideHandler<UIButton>) {

        objc_setAssociatedObject(
            self,
            &AssociatedObjectKey.genericTouchUpInsideHandler,
            genericTouchUpInsideHandler,
            .OBJC_ASSOCIATION_RETAIN
        )

        self.addTarget(
            self,
            action: #selector(handleButtonTouchEvent(sender:)),
            for: .touchUpInside
        )

    }

    /// This Private method is used for handle the touch event of UIButton.
    ///
    /// - Parameter sender: UIButton.
    @objc private func handleButtonTouchEvent(sender: UIButton) {

        if let genericTouchUpInsideHandler = objc_getAssociatedObject(self, &AssociatedObjectKey.genericTouchUpInsideHandler) as?  GenericTouchUpInsideHandler<UIButton> {
            genericTouchUpInsideHandler(sender)
        }
    }
}

// MARK: - Extension of UIButton For getting the IndexPath of UIButton that's exist on UITableView. -

extension UIButton {

    /// This method is used For getting the IndexPath of UIButton that's exist on UITableView.
    ///
    /// - Parameter tableView: A UITableView.
    /// - Returns: This Method returns IndexPath? , it means this method return nil value also , while using this method please use if let. If you are not using if let and if this method returns nil and when you are trying to unwrapped this value("IndexPath!") then application will crash.
    func toIndexPath(tableView: UITableView) -> IndexPath? {

        return tableView.indexPathForRow(
            at: convert(
                CGPoint.zero,
                to: tableView
            )
        )

    }
}

extension UIButton {
    var fontSize: CGFloat { return 14 }
    var normalFont: UIFont { return UIFont.custom(name: .futuraRegular, size: fontSize) }
    
    func setNormalTitle(_ normalTitle: String?) {
        setTitle(
            normalTitle,
            for: .normal
        )
    }

    func setSelectedTitle(_ selectedTitle: String?) {
        setTitle(
            selectedTitle,
            for: .selected
        )
    }

    func setHighLightedTitle(_ highLightedTitle: String?) {
        setTitle(
            highLightedTitle,
            for: .highlighted
        )
    }

    func setTitles(
        normalTitle: String? = nil,
        selectedTitle: String? = nil,
        highLightedTitle: String? = nil
    ) {
        self.setNormalTitle(normalTitle)
        self.setSelectedTitle(selectedTitle)
        self.setHighLightedTitle(highLightedTitle)
    }
    
    func underlineTitle(_ value: String, font: UIFont? = nil) {
        let uploadString = NSMutableAttributedString().underlined(
            value,
            font: font ?? normalFont
        )
        self.setAttributedTitle(uploadString, for: .normal)
    }

}

extension UIButton {

    func setNormalImage(normalImgName: String) {
        setImage(
            UIImage(named: normalImgName),
            for: .normal
        )
    }

    func setSelectedImage(selectedImgName: String) {
        setImage(
            UIImage(named: selectedImgName),
            for: .selected
        )
    }

    func setHighLightedImage(highLightedImgName: String) {
        setImage(
            UIImage(named: highLightedImgName),
            for: .highlighted
        )
    }

    func setImages(
        normalImgName: String? = nil,
        selectedImgName: String? = nil,
        highLightedImgName: String? = nil
    ) {

        if let image = normalImgName {
            setNormalImage(normalImgName: image)
        }

        if let image = selectedImgName {
            setSelectedImage(selectedImgName: image)
        }

        if let image = highLightedImgName {
            setHighLightedImage(highLightedImgName: image)
        }
    }
}

extension UIButton {

    func setNormalTitleColor(_ color: UIColor?) {
        setTitleColor(
            color,
            for: .normal
        )
    }

    func setSelectedTitleColor(_ color: UIColor?) {
        setTitleColor(
            color,
            for: .selected
        )
    }

    func setHighLightedTitleColor(_ color: UIColor?) {
        setTitleColor(
            color,
            for: .highlighted
        )
    }

    func setTitleColors(normalColor: UIColor? = nil, selectedColor: UIColor? = nil, highLightedColor: UIColor? = nil) {

        setNormalTitleColor(normalColor)
        setSelectedTitleColor(selectedColor)
        setHighLightedTitleColor(highLightedColor)
    }
}

extension UIButton {
   func setEnable(_ to: Bool) {
       self.isEnabled = to
       self.backgroundColor = to ? .black : .lightGray
       self.setNormalTitleColor(to ? .white : .darkGray)
   }
}

extension UIButton {
    /// disableFor use to disable button according TimeInterval
    /// - Parameter seconds: Pass dealy time to disbale button
    func disableFor(_ seconds: TimeInterval = 1) {
        isEnabled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.isEnabled = true
        }
    }
}

extension UIButton {
    @IBInspectable var fontName: String {
        get {
            return self.titleLabel?.font.fontName ?? ""
        }
        set {
            if let fontName = FontName(rawValue: newValue) {
                self.titleLabel?.font = UIFont(name: fontName.rawValue, size: self.titleLabel?.font.pointSize ?? UIFont.systemFontSize) ?? UIFont.custom(name: .futuraRegular, size: self.titleLabel?.font.pointSize ?? UIFont.systemFontSize)
            } else {
                print("Invalid font name: \(newValue). Falling back to system font.")
                self.titleLabel?.font = UIFont.custom(name: .futuraRegular, size: self.titleLabel?.font.pointSize ?? UIFont.systemFontSize)
            }
        }
    }
    
    @IBInspectable var cFontSize: CGFloat {
        get {
            return self.titleLabel?.font.pointSize ?? UIFont.systemFontSize
        }
        set {
            self.titleLabel?.font = self.titleLabel?.font.withSize(newValue)
        }
    }
}
