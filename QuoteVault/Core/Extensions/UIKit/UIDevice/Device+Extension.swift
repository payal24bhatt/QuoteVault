//
//  Device+Extension.swift
//

import Foundation
import UIKit

// MARK: - Device Dimensions -

extension UIDevice {

    static var mainScreen: UIScreen {
        return UIScreen.main
    }

    static var screenSize: CGSize {
        return self.mainScreen.bounds.size
    }

    static var screenOrigin: CGPoint {
        return self.mainScreen.bounds.origin
    }

    static var screenX: CGFloat {
        return self.screenOrigin.x
    }

    static var screenY: CGFloat {
        return self.screenOrigin.y
    }

    static var screenCenter: CGPoint {
        return CGPoint(
            x: self.screenWidth/2.0,
            y: self.screenHeight/2.0
        )
    }

    static var screenCenterX: CGFloat {
        return self.screenCenter.x
    }

    static var screenCenterY: CGFloat {
        return self.screenCenter.y
    }

    static var screenWidth: CGFloat {
        return self.screenSize.width
    }

    static var screenHeight: CGFloat {
        return self.screenSize.height
    }

    static var safeAreaHeight: CGFloat {

        guard let window: UIWindow = UIWindow.keyWindow else {
            return 0
        }

        if #available(iOS 11.0, *),
            UIWindow.instancesRespond(to: #selector(getter: window.safeAreaInsets)) {
            return self.screenHeight - window.safeAreaInsets.bottom - window.safeAreaInsets.top
        } else {
            let window = UIWindow.keyWindow
            let height = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            return self.screenHeight - height
        }
    }

    static var safeAreaWidth: CGFloat {

        guard let window: UIWindow = UIWindow.keyWindow else {
            return 0
        }

        if #available(iOS 11.0, *),
            UIWindow.instancesRespond(to: #selector(getter: window.safeAreaInsets)) {
            return self.screenWidth - window.safeAreaInsets.left - window.safeAreaInsets.right
        } else {
            return self.screenWidth
        }
    }

    static var tabBarHeight: CGFloat {
        return 65 + self.safeAreaInsets.bottom
    }

    static var safeAreaBottom: CGFloat {
        guard let window: UIWindow = UIWindow.keyWindow else {
            return 0
        }

        if #available(iOS 11.0, *),
            UIWindow.instancesRespond(to: #selector(getter: window.safeAreaInsets)) {
            return UIDevice.safeAreaInsets.bottom
        } else {
            return 0
        }
    }

    static var safeAreaInsets: UIEdgeInsets {
        guard let window: UIWindow = UIWindow.keyWindow else {
            return .zero
        }

        if #available(iOS 11.0, *),
            UIWindow.instancesRespond(to: #selector(getter: window.safeAreaInsets)) {
            return window.safeAreaInsets
        }

        return .zero
    }

    static var safeAreaLayoutGuide: UILayoutGuide {
        guard let window: UIWindow = UIWindow.keyWindow else {
            return UILayoutGuide()
        }

        if #available(iOS 11.0, *) {
            return window.safeAreaLayoutGuide
        }

        return UILayoutGuide()
    }

    static var navigationBarHeight: CGFloat {
        if #available(iOS 11.0, *) {
            return 44 + UIWindow().safeAreaInsets.top
        } else {
            return 44 + Constants.sharedApplication.statusBarFrame.height
        }
    }
}

// MARK: - Device Details -
extension UIDevice {

    static var CUUId: String {
        return self.current.identifierForVendor?.uuidString ?? ""
    }

    static var deviceName: String {
        return self.current.name
    }

    static var version: String {
        return self.current.systemVersion
    }

}

// MARK: - Device Placement -
extension UIDevice {

    static var deviceOrientation: UIDeviceOrientation {
        return self.current.orientation
    }

    static var isPortrait: Bool {
        return self.deviceOrientation.isPortrait
    }

    static var isLandscape: Bool {
        return self.deviceOrientation.isLandscape
    }

}

// MARK: - Device type -
extension UIDevice {

    /*static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }*/

    static var isIPhone: Bool {
        return self.current.userInterfaceIdiom == .phone
    }

    static var isIPad: Bool {
        return self.current.userInterfaceIdiom == .pad
    }

    static var isTV: Bool {
        return self.current.userInterfaceIdiom == .tv
    }

    static var isIOS9: Bool {
        return ((self.version.convert() as Double).convert() as Int ) == 9
    }

    static var isIOS10: Bool {
        return ((self.version.convert() as Double).convert() as Int ) == 10
    }

    static var isIOS11: Bool {
        return ((self.version.convert() as Double).convert() as Int ) == 11
    }

    static var isIPhone5: Bool {
        return self.screenHeight == 568
    }

    static var isIPhone6: Bool {
        return self.screenHeight == 667
    }

    static var isIPhone6Plus: Bool {
        return self.screenHeight == 736
    }

    static var isIPhoneX: Bool {
        return self.screenHeight == 812
    }

    static var isIPhoneXR: Bool {
        return self.screenHeight == 896
    }

    static var isIPhoneXSeries: Bool {
        return self.screenHeight >= 812 && UIDevice.isIPhone
    }

    static var hasNotch: Bool {

        let keyWindow = UIWindow.keyWindow
        let bottom = keyWindow?.safeAreaInsets.bottom ?? 0
        return (bottom > 0)
    }
}
