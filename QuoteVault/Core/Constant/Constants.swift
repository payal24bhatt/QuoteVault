//
//  Constants.swift
//

import Foundation
import UIKit
import AVFoundation

// MARK: - Common Constant -

typealias VoidClosure = () -> Void
typealias StringClosure = (_ message:String) -> Void
typealias BoolClosure = (_ status:Bool) -> Void
typealias IndexClosure = ((_ index:Int) -> Void)

func getAutoDimension(size:CGFloat) -> CGFloat {
    return ((UIDevice.screenWidth * size) / 375.0)
}

var topMostViewController: UIViewController? {
    return UIApplication.topViewController()
}

/// ScreenSize struct is used to get screen width and height
struct ScreenSize {
    static let width = UIScreen.main.bounds.size.width
    static let height = UIScreen.main.bounds.size.height
}

/// AnimationName enum is used to get animation file name
enum AnimationName: String {
    case splash = "anim_splash"
}

func print(_ item: @autoclosure () -> Any, separator: String = " ", terminator: String = "\n") {
#if DEBUG
    Swift.print(item(), separator: separator, terminator: terminator)
#endif
}

/// AssignedTags is used to global view tag for specific view
struct AssignedTags {
    static let noInternetView = 7777
    static let networkView = 5022
    static let toastAlertView = 200
    static let blurView = 172839
    static let textfieldPlaceholder = 100
}

/// NotificationKeys is string enum type used for notification key
enum NotificationKeys: String {
    case unreadCount
}

/// Constants struct is used for contant value which is used in application
struct Constants {
    
    static let firebaseClientID = "220191274253-hcqm95um86da1bvlvads2hjrnuv7rm8j.apps.googleusercontent.com"
    static let serverClientID = "220191274253-qr1rhlsq61rgc2mln7ucklut18rcecqp.apps.googleusercontent.com"
    static let firebaseReversedClientID = "com.googleusercontent.apps.220191274253-hcqm95um86da1bvlvads2hjrnuv7rm8j"

    static let kClientID = "3a0725d8-9673-432d-a402-68c7df278271"
    static let kGraphEndpoint = "https://graph.microsoft.com/"
    static let kAuthority = "https://login.microsoftonline.com/common"
    static let kRedirectUri = "msauth.com.biz.recce://auth" //"msauth.com.biz.recce://auth"
    static let kScopes: [String] = ["user.read"]
    
    static let elasticSearchKey = "QotMf2cOrg4dh1PyHD2Gq82ZWBCa4VUA9hTbI5Qr"
    static let appStoreURL = "https://apps.apple.com/gb/app/recce/id6744403307"
    static let apiBaseURL = "\(AppInfo.apiBaseDomain)/"
    static let loadImageURL = "\(AppInfo.imageLoadURL)/"
    static let searchApiURL = "\(AppInfo.elasticSearchURL)/"
    static let currencySymbol = "$"
    static let countryCode = "+44"
    static let deviceType = "iOS"
    static let tokenExpiredTime: TimeInterval = 30 * 24 * 60 * 60
    static let imageMaxMB: Int = 5 * 1024 * 1024
    static let perPageRecord: Int = 10
    static let otpRequestTime = 59
    static let maxImageLimit = 5

    static var textfieldTextLimit : (kMinLength:Int,kMaxLength:Int) {
        return (3,50)
    }
    static var passwordLimit : (minLength:Int,maxLength:Int) {
        return (8,20)
    }
    
    static var ageLimit : (maxAge: Date, minAge : Date) {
        return ((Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()), (Calendar.current.date(byAdding: .year, value: -100, to: Date()) ?? Date()))
    }
    
    static var setTimeIntervalSince1900 = Calendar.current.date(from: DateComponents(year: 1900, month: 1, day: 1))
    static var setTimeIntervalSince1980 = Calendar.current.date(from: DateComponents(year: 1980, month: 1, day: 1))
    
    static let sharedApplication = UIApplication.shared
    static let appDelegate = sharedApplication.delegate as! AppDelegate
    
    struct AppInfo {
        static let CMainBundle = Bundle.main
        static let CBundleIdentifier = CMainBundle.bundleIdentifier
        static let CBundleInfoDictionary = CMainBundle.infoDictionary
        static let CVersionNumber = CBundleInfoDictionary?.valueForString(key: "CFBundleShortVersionString")
        static let CBuildNumber = CBundleInfoDictionary?.valueForString(key: "CFBundleVersion")
        static let CApplicationName = CBundleInfoDictionary?.valueForString(key: "CFBundleDisplayName")
        static let appName = CBundleInfoDictionary?.valueForString(key: "CFBundleName")
        static let apiBaseDomain = CBundleInfoDictionary?.valueForString(key: "APIBaseURL") ?? ""
        static let imageLoadURL = CBundleInfoDictionary?.valueForString(key: "imageS3URL") ?? ""
        static let elasticSearchURL = CBundleInfoDictionary?.valueForString(key: "APISearchURL") ?? ""
        static let cmsPageDomain = CBundleInfoDictionary?.valueForString(key: "CMSPageURL") ?? ""
        static let appEnvironment = CBundleInfoDictionary?.valueForString(key: "AppEnv") ?? ""
    }
}

/// Global struct is used for globle method in application
struct Global {
    /// openSettings method is used to opne app setting
    static func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    /// openWebpage is used to open web page of url given
    /// - Parameter url: URL type
    static func openWebpage(url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    /// Generates a unique identifier using the current timestamp.
    ///
    /// - Returns: A string representation of the unique identifier.
    static func generateUniqueID() -> String {
        let timestamp = Date().timeIntervalSince1970
        let uniqueID = String(format: "%.0f", timestamp)
        return uniqueID
    }
    
    /// check app device has notch or not and return true or false
    static func checkHasNotch() -> Bool {
        if #available(iOS 11.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                    let topSafeAreaInset = keyWindow.safeAreaInsets.top
                    if topSafeAreaInset > 20 {
                        return true
                    } else {
                        return false
                    }
                }
            }
            return true
        }
    }
    
    // Helper function to remove special characters
    static func removeSpecialCharacters(from string: String?) -> String? {
        guard let inputString = string else {
            return ""
        }
        
        let allowedCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        let filteredString = inputString.components(separatedBy: allowedCharacterSet.inverted).joined()
        return filteredString
    }
    
 
    /// Generates an image with initials based on the provided name, size, and font size.
    /// - Parameters:
    ///   - name: The name used to generate initials.
    ///   - size: The size of the image.
    ///   - fontSize: The font size of the initials.
    /// - Returns: An optional UIImage with generated initials.
    static func getIntialsImage(name: String, size: CGSize, fontSize: CGFloat = 30) -> UIImage? {
        // Set a default size if the provided size is zero
        let sizeManual: CGSize = size == CGSize(width: 0.0, height: 0.0) ? CGSize(width: 16, height: 16) : size
        let viewBG = UIView(frame: CGRect(origin: .zero, size: sizeManual))
       // viewBG.layer.cornerRadius = sizeManual.width / 2 // Uncommented to make it circular
        viewBG.backgroundColor = .white // Changed to .white for clarity

        // Create the label for initials
        let lblNameInitialize = UILabel(frame: CGRect(origin: .zero, size: sizeManual))
        lblNameInitialize.text = name.first?.uppercased().trim ?? ""
        lblNameInitialize.textAlignment = .center
        lblNameInitialize.textColor = .black // Changed to .black for clarity
        lblNameInitialize.font = UIFont.systemFont(ofSize: 14)
        
        // Adjust the font size if the character is too large for the view
        let maxFontSize: CGFloat = fontSize
        let minFontSize: CGFloat = 10 // Set a minimum font size
        lblNameInitialize.adjustsFontSizeToFitWidth = true
        lblNameInitialize.minimumScaleFactor = minFontSize / maxFontSize
        lblNameInitialize.numberOfLines = 1 // Ensure it fits in one line

        viewBG.addSubview(lblNameInitialize)

        // Create the image from the view
        UIGraphicsBeginImageContext(viewBG.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            viewBG.layer.render(in: context)
        }
        let initialImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return initialImage
    }
    
}

extension Notification.Name {
    static let notifyUnreadNotificationCount = Notification.Name("notifyUnreadNotificationCount")
    static let notifyReloadHomeApi = Notification.Name("notifyReloadHomeApi")
    static let notifyScrollToTop = Notification.Name("notifyScrollToTop")
    static let notifyMyProfileApi = Notification.Name("notifyMyProfileApi")
    static let notifyMyProfileReloadData = Notification.Name("notifyMyProfileReloadData")
    static let notifyReloadEditProfile = Notification.Name("notifyReloadEditProfile")
    static let notifyCommentCountUpdate = Notification.Name("notifyCommentCountUpdate")
    static let notifyForFollowFollowingList = Notification.Name("notifyForFollowFollowingList")
    static let notifyReloadDraftList  = Notification.Name("notifyReloadDraftList")
}

extension Encodable {

    func toDictionary() -> [String: Any]? {

        guard let data = try? JSONEncoder().encode(self) else { return nil }

        return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

    }

}

 
//extension Collection {
//    subscript(safe index: Index) -> Element? {
//        return indices.contains(index) ? self[index] : nil
//    }
//}


extension UIViewController {
    static let swizzleViewDidAppear: Void = {
        let originalSelector = #selector(viewDidAppear(_:))
        let swizzledSelector = #selector(swizzled_viewDidAppear(_:))
        
        guard
            let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector),
            let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector)
        else { return }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    @objc func swizzled_viewDidAppear(_ animated: Bool) {
        swizzled_viewDidAppear(animated)
        print("📘 \(type(of: self)) appeared")
    }
}
