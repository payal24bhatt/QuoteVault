//
//  UIViewController+Alert.swift
//

import Foundation
import UIKit

public enum AAction: Equatable {

    case ok
    case yes
    case no
    case cancel
    case edit
    case delete
    case custom(title:String)

    var title: String {
        switch self {
        case .ok:
            return "ok"
        case .yes:
            return "yes"
        case .no:
            return "no"
        case .cancel:
            return "cancel"
        case .edit:
            return "edit"
        case .delete:
            return "delete"

        case .custom(let title):
            return title
        }
    }

    var style: UIAlertAction.Style {
        switch self {
        case .cancel:
            return .cancel
        case .delete:
            return .destructive
        default:
            return .default
        }
    }
}

// MARK: - Extension of UIViewController For AlertView with Different Numbers of Buttons -

extension UIViewController {

    func alertView(title: String? = "Quote Vault", message: String? = nil, style: UIAlertController.Style = .alert, actions: [AAction] = [],  handler: ((AAction) -> Void)? = nil) {

        DispatchQueue.main.async {
            var _actions = actions
            if actions.isEmpty {
                _actions.append(AAction.ok)
            }
            var arrAction: [UIAlertAction] = []
            let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
            let onSelect: ((UIAlertAction) -> Void)? = { (alert) in
                guard let index = arrAction.index(of: alert) else {
                    return
                }
                handler?(_actions[index])
            }
            for action in _actions {
               // arrAction.append(UIAlertAction(title: action.title, style: action.style, handler: onSelect))
                
                let alertAction = UIAlertAction(title: action.title, style: action.style, handler: onSelect)
                arrAction.append(alertAction)
                
                // Change action title color to orange
                if let textColor = UIColor.red as? AnyObject {
                    alertAction.setValue(textColor, forKey: "titleTextColor")
                }
            }
            _ = arrAction.map({alertController.addAction($0)})
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: - Extension of UIViewController For AlertView with Different Numbers of UITextField and with Two Buttons. -

extension UIViewController {

    /// This Method is used to show AlertView with one TextField and with Two Buttons.
    ///
    /// - Parameters:
    ///   - alertTitle: A String value that indicates the title of AlertView , it is Optional so you can pass nil if you don't want Alert Title.
    ///   - alertMessage: A String value that indicates the title of AlertView , it is Optional so you can pass nil if you don't want alert message.
    ///   - alertFirstTextFieldHandler: TextField Handler , you can directlly get the object of UITextField.
    ///   - btnOneTitle: A String value - Title of button one.
    ///   - btnOneTapped: Button One Tapped Handler (Optional - you can pass nil if you don't want any action).
    ///   - btnTwoTitle: A String value - Title of button two.
    ///   - btnTwoTapped: Button Two Tapped Handler (Optional - you can pass nil if you don't want any action).
    func presentAlertViewWithOneTextField(alertTitle: String?, alertMessage: String?, alertFirstTextFieldHandler: @escaping AlertTextFieldHandler, btnOneTitle: String, btnOneTapped: AlertActionHandler, btnTwoTitle: String, btnTwoTapped: AlertActionHandler) {

        let alertController = UIAlertController(title: alertTitle ?? "", message: alertMessage ?? "", preferredStyle: .alert)
        alertController.addTextField { (alertTextField) in
            alertFirstTextFieldHandler(alertTextField)
        }
        alertController.addAction(UIAlertAction(title: btnOneTitle, style: .default, handler: btnOneTapped))
        alertController.addAction(UIAlertAction(title: btnTwoTitle, style: .default, handler: btnTwoTapped))
        self.present(alertController, animated: true, completion: nil)
    }

    /// This Method is used to show AlertView with two TextField and with Two Buttons.
    ///
    /// - Parameters:
    ///   - alertTitle: A String value that indicates the title of AlertView , it is Optional so you can pass nil if you don't want Alert Title.
    ///   - alertMessage: A String value that indicates the title of AlertView , it is Optional so you can pass nil if you don't want alert message.
    ///   - alertFirstTextFieldHandler: First TextField Handeler , you can directlly get the object of First UITextField.
    ///   - alertSecondTextFieldHandler: Second TextField Handeler , you can directlly get the object of Second UITextField.
    ///   - btnOneTitle: A String value - Title of button one.
    ///   - btnOneTapped: Button One Tapped Handler (Optional - you can pass nil if you don't want any action).
    ///   - btnTwoTitle: A String value - Title of button two.
    ///   - btnTwoTapped: Button Two Tapped Handler (Optional - you can pass nil if you don't want any action).
    func presentAlertViewWithTwoTextFields(
        alertTitle: String?,
        alertMessage: String?,
        alertFirstTextFieldHandler: @escaping AlertTextFieldHandler,
        alertSecondTextFieldHandler: @escaping AlertTextFieldHandler,
        btnOneTitle: String,
        btnOneTapped: AlertActionHandler,
        btnTwoTitle: String,
        btnTwoTapped: AlertActionHandler) {

        let alertController = UIAlertController(title: alertTitle ?? "", message: alertMessage ?? "", preferredStyle: .alert)

        alertController.addTextField { (alertFirstTextField) in
            alertFirstTextFieldHandler(alertFirstTextField)
        }
        alertController.addTextField { (alertSecondTextField) in
            alertSecondTextFieldHandler(alertSecondTextField)
        }
        alertController.addAction(UIAlertAction(title: btnOneTitle, style: .default, handler: btnOneTapped))
        alertController.addAction(UIAlertAction(title: btnTwoTitle, style: .default, handler: btnTwoTapped))
        self.present(alertController, animated: true, completion: nil)
    }

    /// This Method is used to show AlertView with three TextField and with Two Buttons.
    ///
    /// - Parameters:
    ///   - alertTitle: A String value that indicates the title of AlertView , it is Optional so you can pass nil if you don't want Alert Title.
    ///   - alertMessage: A String value that indicates the title of AlertView , it is Optional so you can pass nil if you don't want alert message.
    ///   - alertFirstTextFieldHandler: First TextField Handeler , you can directlly get the object of First UITextField.
    ///   - alertSecondTextFieldHandler: Second TextField Handeler , you can directlly get the object of Second UITextField.
    ///   - alertThirdTextFieldHandler: Third TextField Handeler , you can directlly get the object of Third UITextField.
    ///   - btnOneTitle:  A String value - Title of button one.
    ///   - btnOneTapped: Button One Tapped Handler (Optional - you can pass nil if you don't want any action).
    ///   - btnTwoTitle:  A String value - Title of button two.
    ///   - btnTwoTapped: Button Two Tapped Handler (Optional - you can pass nil if you don't want any action).
    func presentAlertViewWithThreeTextFields(
        alertTitle: String?,
        alertMessage: String?,
        alertFirstTextFieldHandler: @escaping AlertTextFieldHandler,
        alertSecondTextFieldHandler: @escaping AlertTextFieldHandler,
        alertThirdTextFieldHandler: @escaping AlertTextFieldHandler,
        btnOneTitle: String,
        btnOneTapped: AlertActionHandler,
        btnTwoTitle: String,
        btnTwoTapped: AlertActionHandler) {

        let alertController = UIAlertController(title: alertTitle ?? "", message: alertMessage ?? "", preferredStyle: .alert)
        alertController.addTextField { (alertFirstTextField) in
            alertFirstTextFieldHandler(alertFirstTextField)
        }
        alertController.addTextField { (alertSecondTextField) in
            alertSecondTextFieldHandler(alertSecondTextField)
        }
        alertController.addTextField { (alertThirdTextField) in
            alertThirdTextFieldHandler(alertThirdTextField)
        }
        alertController.addAction(UIAlertAction(title: btnOneTitle, style: .default, handler: btnOneTapped))
        alertController.addAction(UIAlertAction(title: btnTwoTitle, style: .default, handler: btnTwoTapped))
        self.present(alertController, animated: true, completion: nil)
    }
}
