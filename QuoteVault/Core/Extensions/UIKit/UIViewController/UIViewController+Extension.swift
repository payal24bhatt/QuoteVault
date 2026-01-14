//
//  UIViewController+Extension.swift
//

import Foundation
import UIKit

extension UIViewController {

    class var storyboardID: String {
        return "\(self)"
    }

    static func instantiateFrom(appStoryboard: AppStoryboard) -> Self? {
        return appStoryboard.viewController(viewControllerClass: self)
    }

    func showController(vc: UIViewController, presentationStyle: UIModalPresentationStyle = .fullScreen, transitionStyle: UIModalTransitionStyle = .crossDissolve) {

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = presentationStyle
        nav.modalTransitionStyle = transitionStyle
        self.present(nav, animated: true, completion: nil)
    }

    func getViewControllerFromTabBar<T: UIViewController>(_ vc: T.Type) -> T? {

        let arrCnt = self.tabBarController?.viewControllers ?? []
        for cnt in arrCnt where cnt is UINavigationController {
            let arrObj = (cnt as! UINavigationController).viewControllers
            for obj in arrObj where obj.isKind(of: vc.classForCoder()) {
                return obj as? T
            }
        }
        return nil
    }

    func getViewControllerFromNavigation<T: UIViewController>(_ vc: T.Type) -> T? {
        var arrCnt : [UIViewController] = []

        if self is UINavigationController {
            arrCnt = (self as? UINavigationController)?.viewControllers ?? []
        } else {
            arrCnt = self.navigationController?.viewControllers ?? []
        }
        for obj in arrCnt where obj.isKind(of: vc.classForCoder()) {
            return obj as? T
        }
        return nil
    }

    func clearNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = .clear
        let attrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFontSize
        ]
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = attrs
    }
}

extension UIViewController {
    func pushVC(vc:UIViewController, isHideBottomBar: Bool = true, animated: Bool = true) {
        vc.hidesBottomBarWhenPushed = isHideBottomBar
        self.navigationController?.pushViewController(vc, animated: animated)
    }
    
    func presentVC(vc:UIViewController, animated: Bool = true) {
        vc.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(vc, animated: animated)
    }
    
    func popVC(isHideBottomBar: Bool = true, animated: Bool = true) {
        self.navigationController?.popViewController(animated: animated)
    }
    
    func popToVC<T:UIViewController>(controllerClass:T.Type?) -> Bool {
        for vc in (self.navigationController?.viewControllers) ?? []{
            if vc.isKind(of:controllerClass!) {
                self.navigationController?.popToViewController(vc, animated: true)
                return true
            }
        }
        return false
    }
    
    func topMostViewController() -> UIViewController {
        if let presentedVC = self.presentedViewController {
            return presentedVC.topMostViewController()
        }
        if let navVC = self as? UINavigationController {
            return navVC.visibleViewController?.topMostViewController() ?? self
        }
        if let tabVC = self as? UITabBarController {
            return tabVC.selectedViewController?.topMostViewController() ?? self
        }
        return self
    }
}
