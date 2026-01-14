//
//  UINavigationController+Extension.swift
//

import Foundation
import UIKit

// MARK: - Extension of UINavigationController For assigning the RootViewController of UINavigationController. -

extension UINavigationController {

    /// This static method is used For assigning the RootViewController of UINavigationController.
    ///
    /// - Parameter viewController: Pass the UIViewController's instance for set it as RootViewController of UINavigationController.
    /// - Returns: RootViewController of UINavigationController.
    static func rootViewController(viewController: UIViewController) -> UINavigationController {

        return self.init(rootViewController: viewController)
    }

    /// This method is used to getting back to any UIViewController among UIViewController's Stack.
    ///
    /// - Parameters:
    ///   - viewController: Pass the UIViewController's instance for which you want to get back.
    ///   - animated: A Bool Value for Animated OR Not.
    func popToViewController(viewController: UIViewController, animated: Bool = true) {

        for vc in self.viewControllers where vc.isKind(of: viewController.classForCoder) {
            self.popToViewController(vc, animated: animated)
        }
    }

    /// This method is used to pop view controller with Completion Block.
    ///
    /// - Parameters:
    ///   - animated: A Bool Value for Animated OR Not.
    ///   - completion: Completion block for pop action.
    func popViewController(animated: Bool, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popViewController(animated: true)
        CATransaction.commit()
    }

    /// This method is used to check the presented ViewController.
    ///
    /// - Parameters:
    ///   - viewController: Pass the UIViewController's instance for which you want to check.
    static func hasPresented(viewController: UIViewController) -> Bool {

        let presentingIsModal = viewController.presentingViewController != nil

        let presentingIsNavigation = viewController.navigationController?.presentingViewController?.presentedViewController == viewController.navigationController

        let presentingIsTabBar = viewController.tabBarController?.presentingViewController is UITabBarController

        return presentingIsModal || presentingIsNavigation || presentingIsTabBar
    }
}

extension UINavigationController {
    func addCustomBottomLine(color:UIColor, height:Double, padding: Double = 0) {
        // Hiding default line and shadow
        navigationBar.setValue(true, forKey: "hidesShadow")
        
        guard (navigationBar.subviews.filter({$0.tag == 201}).first) == nil else { return }
        
        // Creating new line
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width:0, height: height))
        lineView.tag = 201
        lineView.backgroundColor = color
        navigationBar.addSubview(lineView)
        
        // Add constraint
        lineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lineView.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor, constant: padding),
            lineView.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor, constant: -padding),
            lineView.heightAnchor.constraint(equalToConstant: CGFloat(height)),
            lineView.centerXAnchor.constraint(equalTo: navigationBar.centerXAnchor),
            lineView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor)
        ])
    }
    
    func removeBottomLine() {
        if let view = navigationBar.subviews.filter({$0.tag == 201}).first {
            view.removeFromSuperview()
        }
    }
}
