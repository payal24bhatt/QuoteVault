//
//  UIApplication+Extension.swift
//

import Foundation
import UIKit
// import NVActivityIndicatorView

// MARK: - Extension of UIApplication -

extension UIApplication {

    /// This will return the application AppDelegate instance.
    ///
    ///  This could be nil value also, while using this "appDelegate" please use if let. If you are not using if let and if this returns nil and when you are trying to unwrapped this value then application will crash.
    static var appDelegate: AppDelegate? {
        return Constants.sharedApplication.delegate as? AppDelegate
    }

    /// This will return the AppDelegate UIWindow instance.
    ///
    ///  This could be nil value also, while using this "appDelegateWindow" please use if let. If you are not using if let and if this returns nil and when you are trying to unwrapped this value then application will crash.
    static var window: UIWindow? {
        return UIApplication.appDelegate?.window
    }

    /// This will return the AppDelegate rootViewController instance.
    ///
    ///  This could be nil value also, while using this "appDelegateWindowRootViewController" please use if let. If you are not using if let and if this returns nil and when you are trying to unwrapped this value then application will crash.
    static var rootViewController: UIViewController? {
        return UIApplication.window?.rootViewController
    }

    /// This will return the application SceneDelegate instance.
    ///
    ///  This could be nil value also, while using this "sceneDelegate" please use if let. If you are not using if let and if this returns nil and when you are trying to unwrapped this value then application will crash.

    /// This will return the SceneDelegate UIWindow instance.
    ///
    ///  This could be nil value also, while using this "sceneWindow" please use if let. If you are not using if let and if this returns nil and when you are trying to unwrapped this value then application will crash.

    /// This will return the SceneDelegate  instance.
    ///
    /// This could be nil value also, while using this "sceneWindowRootViewController" please use if let. If you are not using if let and if this returns nil and when you are trying to unwrapped this value then application will crash.

    class func topViewController(_ viewController: UIViewController? = UIWindow.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(presented)
        }

        return viewController
    }
}
