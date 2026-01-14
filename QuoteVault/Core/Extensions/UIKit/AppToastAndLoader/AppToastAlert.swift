//
//  AppToastAlert.swift
//

import Foundation
import UIKit

class AppToastAlert {

    private init() {}

    private static let appToastAlert: AppToastAlert = {
        let appToastAlert = AppToastAlert()
        return appToastAlert
    }()
    static var shared: AppToastAlert {
        return appToastAlert
    }

    fileprivate static var animationDuration: TimeInterval = 1.5
    fileprivate static var viewRemovingDuration: TimeInterval = 3.5
    fileprivate static var timer = Timer()
}

extension AppToastAlert {

    enum AppToastAlertPosition {
        case top
        case center
        case bottom
    }
}

extension AppToastAlert {

    fileprivate static let toastAlertView: UIView = {
        let toastAlertView = UIView()
        toastAlertView.tag = AssignedTags.toastAlertView
        toastAlertView.layer.cornerRadius = 3.5
        toastAlertView.backgroundColor = UIColor.rgbToColor(r: 0.0, g: 0.0, b: 0.0, a: 0.0)
        toastAlertView.translatesAutoresizingMaskIntoConstraints = false
        return toastAlertView
    }()

    func setToastalertViewBgColor(color: UIColor?) {

        if var rgba = color?.getRGB() {

            rgba.a = 0.0

            AppToastAlert.toastAlertView.backgroundColor = UIColor.rgbToColor(r: rgba.r * 255.0, g: rgba.g * 255.0, b: rgba.b * 255.0, a: rgba.a)
        }
    }

    func setToastalertViewAlpha(alpha: CGFloat) {

        if var rgba = AppToastAlert.toastAlertView.backgroundColor?.getRGB() {

            rgba.a = alpha

            AppToastAlert.toastAlertView.backgroundColor = UIColor.rgbToColor(r: rgba.r * 255.0, g: rgba.g * 255.0, b: rgba.b * 255.0, a: rgba.a)
        }
    }

    func setToastalertViewCornerRadius(cornerRadius: CGFloat) {
        AppToastAlert.toastAlertView.layer.cornerRadius = cornerRadius
    }
}

extension AppToastAlert {

    fileprivate static let lblMessage: UILabel = {
        let lblMessage = UILabel()
        lblMessage.textAlignment = .center
        lblMessage.textColor = UIColor.rgbToColor(r: 255.0, g: 255.0, b: 255.0, a: 0.0)
        lblMessage.numberOfLines = 0
        lblMessage.translatesAutoresizingMaskIntoConstraints = false
        return lblMessage
    }()

    func setLblMessageTextAlignment(alignment: NSTextAlignment) {
        AppToastAlert.lblMessage.textAlignment = alignment
    }

    func setLblMessageFont(font: UIFont) {
        AppToastAlert.lblMessage.font = font
    }

    func setLblMessageTextColor(textColor: UIColor) {
        AppToastAlert.lblMessage.textColor = textColor
    }

    fileprivate func setLblMessageText(message: String) {
        AppToastAlert.lblMessage.text = message
    }
}

extension AppToastAlert {

    func showToastAlert(position: AppToastAlert.AppToastAlertPosition, message: String) {

        if let toastAlertView = topMostViewController?.view.viewWithTag(AssignedTags.toastAlertView) {
            AppToastAlert.timer.invalidate()
            toastAlertView.removeAllSubviews()
            toastAlertView.removeFromSuperview()
        }

        AppToastAlert.shared.setLblMessageText(message: message)
        self.resizeToastalertView(position: position)
        self.performAnimation()
    }

    private func resizeToastalertView(position: AppToastAlert.AppToastAlertPosition) {
        topMostViewController?.view.addSubview(AppToastAlert.toastAlertView)

        NSLayoutConstraint(item: AppToastAlert.toastAlertView, attribute: .centerX, relatedBy: .equal, toItem: topMostViewController?.view, attribute: .centerX, multiplier: 1.0, constant: 0.0).isActive = true

        NSLayoutConstraint(item: AppToastAlert.toastAlertView, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: UIDevice.screenWidth - 10.0 - 10.0).isActive = true

        var toastAlertViewAttribute: NSLayoutConstraint.Attribute
        var constant: CGFloat
        var appWindowAttribute: NSLayoutConstraint.Attribute

        switch position {

        case .top:
            constant = (UIDevice.isIPhoneXSeries ? 88.0 : 64.0) + 20.0
            toastAlertViewAttribute = .top
            appWindowAttribute = .top

        case .center:
            constant = 0.0
            toastAlertViewAttribute = .centerY
            appWindowAttribute = .centerY

        case .bottom:
            constant = (UIDevice.isIPhoneXSeries ? -(34.0 + 20.0 + 50.0) : -20.0)
            toastAlertViewAttribute = .bottom
            appWindowAttribute = .bottom

        }

        NSLayoutConstraint(item: AppToastAlert.toastAlertView, attribute: toastAlertViewAttribute, relatedBy: .equal, toItem: topMostViewController?.view, attribute: appWindowAttribute, multiplier: 1.0, constant: constant).isActive = true

        AppToastAlert.toastAlertView.addSubview(AppToastAlert.lblMessage)

        NSLayoutConstraint(item: AppToastAlert.lblMessage, attribute: .leading, relatedBy: .equal, toItem: AppToastAlert.toastAlertView, attribute: .leading, multiplier: 1.0, constant: 10.0).isActive = true

        NSLayoutConstraint(item: AppToastAlert.lblMessage, attribute: .top, relatedBy: .equal, toItem: AppToastAlert.toastAlertView, attribute: .top, multiplier: 1.0, constant: 10.0).isActive = true

        NSLayoutConstraint(item: AppToastAlert.lblMessage, attribute: .trailing, relatedBy: .equal, toItem: AppToastAlert.toastAlertView, attribute: .trailing, multiplier: 1.0, constant: -10.0).isActive = true

        NSLayoutConstraint(item: AppToastAlert.lblMessage, attribute: .bottom, relatedBy: .equal, toItem: AppToastAlert.toastAlertView, attribute: .bottom, multiplier: 1.0, constant: -10.0).isActive = true
    }

    fileprivate func performAnimation() {

        UIView.animate(withDuration: AppToastAlert.animationDuration) {

            if var rgba = AppToastAlert.toastAlertView.backgroundColor?.getRGB() {

                rgba.a = 1.0

                AppToastAlert.toastAlertView.backgroundColor = UIColor.rgbToColor(r: rgba.r * 255.0, g: rgba.g * 255.0, b: rgba.b * 255.0, a: rgba.a)
            }

            if var rgba = AppToastAlert.lblMessage.textColor.getRGB() {

                rgba.a = 1.0

                AppToastAlert.lblMessage.textColor = UIColor.rgbToColor(r: rgba.r * 255.0, g: rgba.g * 255.0, b: rgba.b * 255.0, a: rgba.a)
            }
        }

        AppToastAlert.timer = Timer.scheduledTimer(withTimeInterval: AppToastAlert.viewRemovingDuration, repeats: false) { (_timer) in

            UIView.animate(withDuration: AppToastAlert.animationDuration, animations: {

                if var rgba = AppToastAlert.toastAlertView.backgroundColor?.getRGB() {

                    rgba.a = 0.0

                    AppToastAlert.toastAlertView.backgroundColor = UIColor.rgbToColor(r: rgba.r * 255.0, g: rgba.g * 255.0, b: rgba.b * 255.0, a: rgba.a)
                }

            }, completion: { (completion) in

                if completion {

                    _timer.invalidate()
                    AppToastAlert.toastAlertView.removeAllSubviews()
                    AppToastAlert.toastAlertView.removeFromSuperview()
                }
            })
        }
    }
    
    /// Remove Toast From Base vc
    func removeToast() {
        if let toastView = topMostViewController?.view.viewWithTag(AssignedTags.toastAlertView) {
            toastView.removeAllSubviews()
            toastView.removeFromSuperview()
        }
        
    }
}
