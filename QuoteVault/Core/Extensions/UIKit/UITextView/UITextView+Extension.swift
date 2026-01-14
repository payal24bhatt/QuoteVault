import Foundation
import UIKit

// MARK: - Associated Object Keys (must be file-scope globals)
private var errorKey: UInt8 = 0
private var errorLabelKey: UInt8 = 0

extension UITextView {
    
    // MARK: - Error Handling
    var error: String? {
        get {
            return objc_getAssociatedObject(self, &errorKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &errorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if let errorText = newValue, !errorText.isEmpty {
                showError(errorText)
            } else {
                hideError()
            }
        }
    }
    
    private var errorLabel: UILabel {
        if let label = objc_getAssociatedObject(self, &errorLabelKey) as? UILabel {
            return label
        } else {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = .red
            label.numberOfLines = 0
            label.isHidden = true
            label.translatesAutoresizingMaskIntoConstraints = false
            
            if let superview = self.superview {
                superview.addSubview(label)
                NSLayoutConstraint.activate([
                    label.topAnchor.constraint(equalTo: self.bottomAnchor, constant: 4),
                    label.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                    label.trailingAnchor.constraint(equalTo: self.trailingAnchor)
                ])
            }
            
            objc_setAssociatedObject(self, &errorLabelKey, label, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return label
        }
    }
    
    private func showError(_ message: String) {
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 1
        self.errorLabel.text = message
        self.errorLabel.isHidden = false
    }
    
    private func hideError() {
        self.layer.borderWidth = 0
        self.errorLabel.text = nil
        self.errorLabel.isHidden = true
    }
    
    
    // MARK: - Done Accessory
    var trimmed: String {
        return self.text.trim
    }

    @IBInspectable var doneAccessory : Bool {
        get {
            return self.doneAccessory
        }
        set (hasDone) {
            if (hasDone) {
                addDoneButtonOnKeyboard()
            }
        }
    }

    func addDoneButtonOnKeyboard() {

        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIDevice.screenWidth, height: 50))
        doneToolbar.isTranslucent = self.keyboardAppearance == .dark
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        if self.keyboardAppearance == .dark {
            done.tintColor = .white
            doneToolbar.tintColor = .black
        }
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction() {
        self.resignFirstResponder()
    }
}
