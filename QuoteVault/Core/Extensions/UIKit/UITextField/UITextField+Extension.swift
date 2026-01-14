//
//  UITextField+Extension.swift
//

import Foundation
import UIKit

private var key: Void?

private class UITextFieldAdditions: NSObject {
    var readonly: Bool = false
}

extension UITextField {
    func addCountryCodePrefix() {
        var mutableString = NSMutableAttributedString()

        if self.text?.removingWhitespaceAndNewlines() != Constants.countryCode.removingWhitespaceAndNewlines() {
            mutableString = NSMutableAttributedString()
            .normal(Constants.countryCode, fontSize: 14.0,fontColor: .lightGray)
            .normal(self.text?.replacingOccurrences(of: Constants.countryCode, with: "", options: NSString.CompareOptions.literal, range: nil) ?? "nil", fontSize: 14.0,fontColor: .black)
        } else {
            mutableString = NSMutableAttributedString(string: Constants.countryCode)
            mutableString.addAttribute(NSAttributedString.Key.foregroundColor,
                                       value: UIColor.lightGray, range: NSRange(location: 0, length: 3))
        }
        self.attributedText = mutableString
    }
    func manageCountryCodePrefixByShouldChangeCharactersIn(range:NSRange) -> Bool {
        self.typingAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        let protectedRange = NSRange(location: 0, length: Constants.countryCode.count)
        let intersection = NSIntersectionRange(protectedRange, range)
        if intersection.length > 0 {

            return false
        }
        if range.location == 12 {
            return true
        }
        if range.location + range.length > 12 {
            return false
        }
        return true
    }

    func validatedText(validationType: ValidatorType) -> String? {
        let validator = ValidatorFactory.validatorFor(type: validationType)
        let result = validator.validated(self.text!)

        if !(result.status) {
            return result.message
        }
        return nil
    }

    func setLeftPadding(_ _width: CGFloat) {

        let paddingView = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: _width,
            height: self.frame.height
            )
        )

        self.leftView = paddingView
        self.leftViewMode = UITextField.ViewMode.always
    }

    func setRightPadding(_ _width: CGFloat) {

        if (_width > 0) {

            let paddingView = UIView(frame: CGRect(
                x: 0,
                y: 0,
                width: _width,
                height: self.frame.height
                )
            )

            self.rightView = paddingView
            self.rightViewMode = .always
        } else {
            self.rightView = nil
        }
    }

    @IBInspectable var doneAccessory: Bool {
        get {
            return self.doneAccessory
        }
        set (hasDone) {
            if (hasDone) {
                addDoneButtonOnKeyboard()
            }
        }
    }

    private func addDoneButtonOnKeyboard() {

        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(
            x: 0,
            y: 0,
            width: UIDevice.screenWidth,
            height: 50
            )
        )
        
        doneToolbar.isTranslucent = self.keyboardAppearance == .dark

        let flexSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )

        let done: UIBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(self.doneButtonAction)
        )

        if (self.keyboardAppearance == .dark) {
            done.tintColor = .white
        }

        let items = [
            flexSpace,
            done
        ]

        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.inputAccessoryView = doneToolbar
    }

    @objc private func doneButtonAction() {
        self.resignFirstResponder()
    }

    var readonly: Bool {
        get {
            return self.getAdditions().readonly
        } set {
            self.getAdditions().readonly = newValue
        }
    }

    private func getAdditions() -> UITextFieldAdditions {

        var additions = objc_getAssociatedObject(self, &key) as? UITextFieldAdditions

        if (additions == nil) {

            additions = UITextFieldAdditions()
            objc_setAssociatedObject(
                self,
                &key,
                additions!,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN
            )
        }
        return additions!
    }

    open override func target(forAction action: Selector, withSender sender: Any?) -> Any? {

        if ((action == #selector(UIResponderStandardEditActions.paste(_:)) || (action == #selector(UIResponderStandardEditActions.cut(_:)))) && self.readonly) {
            return nil
        }

        return super.target(
            forAction: action,
            withSender: sender
        )
    }

    var trimmed: String {
        return (self.text ?? "").trim
    }

//    func setupLeftImageView(img: UIImage?) {
//
//        let leftImageView = UIImageView(image: img)
//        leftImageView.contentMode = .scaleAspectFit
//
//        let _leftView = UIView()
//        _leftView.clipsToBounds = true
//        _leftView.addSubview(leftImageView)
//
//        leftImageView.center = _leftView.center
//        _leftView.frame = CGRect(
//            x: 0,
//            y: 0,
//            width: 35,
//            height: 35
//        )
//
//        leftImageView.frame = CGRect(
//            x: 5,
//            y: 5,
//            width: 20,
//            height: 20
//        )
//
//        self.leftViewMode = .always
//        self.leftView = _leftView
//    }
    
    func setupLeftImageView(img: UIImage?) {
        let leftImageView = UIImageView(image: img)
        leftImageView.contentMode = .scaleAspectFit

        let _leftView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        
        // Set the image frame to be centered within _leftView
        leftImageView.frame = CGRect(
            x: (_leftView.frame.width - 20) / 2,  // Center horizontally
            y: (_leftView.frame.height - 20) / 2, // Center vertically
            width: 20,
            height: 20
        )

        _leftView.addSubview(leftImageView)

        self.leftViewMode = .always
        self.leftView = _leftView
    }


    func setupRightImageView(img: UIImage?) {

        let rightImageView = UIImageView(image: img)
        rightImageView.contentMode = .scaleAspectFit

        let _rightView = UIView()
        _rightView.clipsToBounds = true
        _rightView.addSubview(rightImageView)

        rightImageView.center = _rightView.center

        _rightView.frame = CGRect(
            x: 0,
            y: 0,
            width: 30,
            height: 40
        )

        rightImageView.frame = CGRect(
            x: 3,
            y: 5,
            width: 24,
            height: 24
        )

        self.rightViewMode = .always
        _rightView.isUserInteractionEnabled = false
        rightImageView.isUserInteractionEnabled = false
        self.rightView?.isUserInteractionEnabled = false
        self.rightView = _rightView
    }

    func isValidated() -> Int {

        guard let _text = self.text else {
            return 1
        }

        if _text.trim.isEmpty {

            let prevPlaceholder = self.placeholderColor
            self.placeholderColor = UIColor(hexString: "#aa1a1a")

            DispatchQueue.main.asyncAfter(
                deadline: .now() + 1,
                execute: {
                    self.placeholderColor = prevPlaceholder
            })

            self.shake()
            return 1
        }
        return 0
    }

    func shake() {

        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.10
        animation.autoreverses = true

        animation.fromValue = NSValue(cgPoint: CGPoint(
            x: self.center.x - 10,
            y: self.center.y))

        animation.toValue = NSValue(cgPoint: CGPoint(
            x: self.center.x + 10,
            y: self.center.y))

        self.layer.add(
            animation,
            forKey: "position"
        )
    }
}

extension UITextField {

    func setupRightImageView(img: UIImage?, target: Any?, action: Selector?) {
            let rightImageView = UIImageView(image: img)
            rightImageView.contentMode = .scaleAspectFit

            let _rightView = UIView()
            _rightView.clipsToBounds = true
            _rightView.addSubview(rightImageView)

            rightImageView.center = _rightView.center

            _rightView.frame = CGRect(
                x: 0,
                y: 0,
                width: 30,
                height: 40
            )

            rightImageView.frame = CGRect(
                x: 3,
                y: 8,
                width: 24,
                height: 24
            )

            self.rightViewMode = .always

            // Add a tap gesture recognizer to _rightView
            let tapGesture = UITapGestureRecognizer(target: target, action: action)
            _rightView.addGestureRecognizer(tapGesture)

            _rightView.isUserInteractionEnabled = true
            rightImageView.isUserInteractionEnabled = false
            self.rightView?.isUserInteractionEnabled = false
            self.rightView = _rightView
        }
    
    // Function to remove the right image view
        func removeRightImageView() {
            self.rightView = nil // Remove the right view
            self.rightViewMode = .never // Ensure the right view mode is set to never
        }
}
private var __maxLengths = [UITextField: Int]()

extension UITextField {
    @IBInspectable
    public var maxLength: Int {
        get {
            guard let length = __maxLengths[self] else {
                return Int.max
            }
            return length
        }
        set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(actionFix), for: .editingChanged)
        }
    }
    
    @objc func actionFix(textField: UITextField) {
        if let text = textField.text {
            textField.text = String(text.prefix(maxLength))
        }
    }
}

extension UITextField {
    func setRightPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

// MARK: - Placeholder Padding (IBInspectable)
private struct PlaceholderPaddingKeys {
    static var paddingBoth = "placeholderPaddingBothKey"
    static var paddingLeft = "placeholderPaddingLeftKey"
    static var paddingRight = "placeholderPaddingRightKey"
}

extension UITextField {
    
    /// Apply equal padding to both leading and trailing sides of the text/placeholder.
    @IBInspectable var placeholderPadding: CGFloat {
        get {
            return objc_getAssociatedObject(self, &PlaceholderPaddingKeys.paddingBoth) as? CGFloat ?? 0
        }
        set {
            objc_setAssociatedObject(self, &PlaceholderPaddingKeys.paddingBoth, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            placeholderLeftPadding = newValue
            placeholderRightPadding = newValue
        }
    }
    
    /// Leading padding for text/placeholder. Use from Interface Builder via IBInspectable.
    @IBInspectable var placeholderLeftPadding: CGFloat {
        get {
            return objc_getAssociatedObject(self, &PlaceholderPaddingKeys.paddingLeft) as? CGFloat ?? 0
        }
        set {
            objc_setAssociatedObject(self, &PlaceholderPaddingKeys.paddingLeft, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if newValue > 0 {
                setLeftPadding(newValue)
            } else {
                leftView = nil
                leftViewMode = .never
            }
        }
    }
    
    /// Trailing padding for text/placeholder. Use from Interface Builder via IBInspectable.
    @IBInspectable var placeholderRightPadding: CGFloat {
        get {
            return objc_getAssociatedObject(self, &PlaceholderPaddingKeys.paddingRight) as? CGFloat ?? 0
        }
        set {
            objc_setAssociatedObject(self, &PlaceholderPaddingKeys.paddingRight, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if newValue > 0 {
                setRightPadding(newValue)
            } else {
                rightView = nil
                rightViewMode = .never
            }
        }
    }
}
